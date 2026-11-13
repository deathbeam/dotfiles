#!/usr/bin/env python3
"""Tests for poe_parser.py. Run: python3 -m unittest discover -s scripts"""

import json
import tempfile
import unittest
from pathlib import Path

import poe_parser as parser

AREAS = {
    "1_1_1": {"name": "Twilight Strand", "act": 1, "level": 1, "recipe": ""},
    "1_1_town": {"name": "Lioneye's Watch", "act": 1, "level": 0, "recipe": ""},
    "1_1_2": {"name": "The Coast", "act": 1, "level": 2, "recipe": ""},
    "1_1_2a": {"name": "Tidal Island", "act": 1, "level": 3, "recipe": ""},
    "1_2_1": {"name": "The Forest", "act": 2, "level": 10, "recipe": "Movement Speed I"},
}


def page(*lines):
    return {"act": 1, "lines": list(lines), "condition": None}


def conditional(condition, *lines):
    return {"act": 1, "lines": list(lines), "condition": condition}


class PageTest(unittest.TestCase):
    def test_areas_skip_hint_lines(self):
        lines = page(
            "enter areaid1_1_2 ;; the coast",
            "(hint)__ then move on to areaid1_1_2a",
        )
        self.assertEqual(parser.page_areas(lines, league_start=False), ["1_1_2"])

    def test_areas_skip_tags_for_other_run_type(self):
        lines = page(
            "leaguestart: enter areaid1_1_2",
            "twinkrun: enter areaid1_1_2a",
        )
        self.assertEqual(parser.page_areas(lines, league_start=False), ["1_1_2a"])
        self.assertEqual(parser.page_areas(lines, league_start=True), ["1_1_2"])

    def test_conditions(self):
        league = conditional(["league-start", "yes"], "x")
        twink = conditional(["league-start", "no"], "x")
        bandit = conditional(["bandit", ["none", "alira"]], "x")
        self.assertTrue(parser.page_matches(league, True, "none"))
        self.assertFalse(parser.page_matches(league, False, "none"))
        self.assertTrue(parser.page_matches(twink, False, "none"))
        self.assertTrue(parser.page_matches(bandit, True, "alira"))
        self.assertFalse(parser.page_matches(bandit, True, "oak"))
        self.assertTrue(parser.page_matches(page("x"), False, "oak"))

    def test_visible_lines_hide_optionals(self):
        lines = page("do this", "optional: maybe this", "(hint)__ sub of optional")
        self.assertEqual(parser.visible_lines(lines, league_start=False), ["do this"])


class TrackerTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.state = Path(self.tmp.name) / "state.json"
        self.pages = [
            page("kill hillock", "enter areaid1_1_town"),
            conditional(["league-start", "yes"], "leaguestart only"),
            page("enter areaid1_1_2"),
            page("enter areaid1_1_2a"),
        ]
        renderer = parser.Renderer(AREAS, {}, Path(self.tmp.name))
        self.tracker = parser.Tracker(AREAS, self.pages, renderer, self.state, league_start=False, bandit="none")

    def tearDown(self):
        self.tmp.cleanup()

    def test_advance_on_target(self):
        self.tracker.enter_area("1_1_1", 1)
        self.assertEqual(self.tracker.page, 0)
        self.tracker.enter_area("1_1_town", 0)  # page 0 targets the town
        self.assertEqual(self.tracker.page, 2)  # league-start page is skipped
        self.tracker.enter_area("1_1_2", 2)
        self.assertEqual(self.tracker.page, 3)

    def test_manual_step_skips_condition(self):
        self.tracker.next_page()
        self.assertEqual(self.tracker.page, 2)
        self.tracker.prev_page()
        self.assertEqual(self.tracker.page, 0)

    def test_progress_persists(self):
        self.tracker.page = 2
        self.tracker.set_level(12)
        self.tracker.save_state()
        reloaded = parser.Tracker(AREAS, self.pages, self.tracker.renderer, self.state, False, "none")
        self.assertEqual((reloaded.page, reloaded.char_level), (2, 12))

    def test_snapshot(self):
        self.tracker.enter_area("1_1_2", 2)
        self.tracker.set_level(3)
        state = self.tracker.snapshot()
        self.assertEqual(state["zone_name"], "The Coast")
        self.assertEqual(state["act"], 1)
        self.assertEqual(state["pages"], len(self.pages))
        self.assertEqual(state["page"], 0)
        self.assertIn("Lioneye", state["lines"][1]["html"])
        self.assertEqual(state["xp"], "100%")


class MarkupTest(unittest.TestCase):
    def setUp(self):
        self.renderer = parser.Renderer(AREAS, {"follow streams": "file:///hints/follow_streams.jpg"}, Path("/nonexistent"))

    def test_area_name_and_act_prefix(self):
        html, _ = self.renderer.render("go to areaid1_2_1 ;; the forest", current_act=1)
        self.assertIn("Act 2 | The Forest", html)
        self.assertIn(parser.COLOR["area"], html)
        self.assertNotIn("the forest", html)  # comment stripped

    def test_quest_tokens(self):
        html, _ = self.renderer.render("tarkleigh: <breaking_some_eggs1> (quest:chest)", current_act=1)
        self.assertIn(parser.COLOR["quest"], html)
        self.assertIn("breaking some eggs", html)
        self.assertIn(parser.COLOR["item"], html)
        self.assertIn("chest", html)

    def test_icon_and_missing_icon(self):
        icon_dir = Path(tempfile.mkdtemp())
        (icon_dir / "waypoint.png").write_bytes(b"")
        renderer = parser.Renderer(AREAS, {}, icon_dir)
        html, _ = renderer.render("(img:waypoint) to areaid1_1_2", current_act=1)
        self.assertIn("<img src=", html)
        html, _ = renderer.render("(img:unknown)", current_act=1)
        self.assertIn("[unknown]", html)

    def test_kill_and_hint_colours(self):
        html, _ = self.renderer.render("kill hillock", current_act=1)
        self.assertIn(parser.COLOR["boss"], html)
        html, hint = self.renderer.render("(hint)_ follow streams", current_act=1)
        self.assertTrue(hint)
        self.assertIn(parser.dim(parser.COLOR["hint"]), html)
        self.assertNotIn("_", html)  # the (hint)_ marker leaves nothing behind

    def test_lilly_tail_and_or(self):
        html, _ = self.renderer.render("buy gems || lilly: <mercy_mission>", current_act=1)
        self.assertNotIn("mercy", html)
        html, _ = self.renderer.render("kill dweller || relog", current_act=1)
        self.assertIn("or", html)


class XpTest(unittest.TestCase):
    def test_on_level(self):
        self.assertEqual(parser.xp_info(1, 1, "1_1_1"), ("100%", parser.XP_COLOR["lime"]))
        self.assertEqual(parser.xp_info(10, 10, "1_2_1")[0], "100%")

    def test_penalty(self):
        text, color = parser.xp_info(24, 15, "1_2_1")
        self.assertEqual(text, "20% (-5)")
        self.assertEqual(color, parser.XP_COLOR["red"])

    def test_small_gap_is_safe(self):
        text, _ = parser.xp_info(24, 22, "1_2_1")
        self.assertEqual(text, "100%")

    def test_town_and_hideout_are_full(self):
        self.assertEqual(parser.xp_info(24, 15, "1_2_town")[0], "100%")
        self.assertEqual(parser.xp_info(24, 15, "hideout")[0], "100%")


class LogTailTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.path = Path(self.tmp.name) / "Client.txt"

    def tearDown(self):
        self.tmp.cleanup()

    def tail(self):
        tail = parser.LogTail(self.path)
        self.addCleanup(tail.close)
        return tail

    def test_follows_appends(self):
        self.path.write_text("one\n")
        tail = self.tail()
        self.assertEqual(tail.read_new(), ["one"])
        with self.path.open("a") as handle:
            handle.write("two\npartial")
        self.assertEqual(tail.read_new(), ["two"])
        with self.path.open("a") as handle:
            handle.write(" line\n")
        self.assertEqual(tail.read_new(), ["partial line"])

    def test_reopens_after_truncate(self):
        self.path.write_text("one\ntwo\n")
        tail = self.tail()
        self.assertEqual(tail.read_new(), ["one", "two"])
        self.path.write_text("three\n")
        self.assertEqual(tail.read_new(), ["three"])

    def test_reopens_after_inode_change(self):
        self.path.write_text("one\n")
        tail = self.tail()
        self.assertEqual(tail.read_new(), ["one"])
        self.path.unlink()
        self.path.write_text("fresh\n")
        self.assertEqual(tail.read_new(), ["fresh"])

    def test_read_all_replays_and_continues(self):
        self.path.write_text("one\ntwo\n")
        tail = self.tail()
        self.assertEqual(tail.read_all(), ["one", "two"])
        with self.path.open("a") as handle:
            handle.write("three\n")
        self.assertEqual(tail.read_new(), ["three"])


class DataTest(unittest.TestCase):
    """The imported data must match what the renderer expects."""

    def test_shipped_data_loads(self):
        data = Path(__file__).resolve().parent.parent / "data"
        areas = parser.load_areas(data / "areas.json")
        pages = parser.load_pages(data / "guide.json")
        hints = parser.load_hints(data / "hints")
        self.assertGreater(len(areas), 100)
        self.assertGreater(len(pages), 100)
        self.assertTrue(hints)
        renderer = parser.Renderer(areas, hints, data / "icons")
        for index, item in enumerate(pages):
            for line in parser.visible_lines(item, league_start=False):
                markup, _ = renderer.render(line, current_act=1)
                self.assertNotIn("(img:", markup, f"page {index}: {line}")
                self.assertNotIn("(quest:", markup, f"page {index}: {line}")
                self.assertNotIn("areaid", markup, f"page {index}: {line}")


if __name__ == "__main__":
    unittest.main()
