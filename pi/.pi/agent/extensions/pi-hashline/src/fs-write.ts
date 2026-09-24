import { randomUUID } from "crypto";
import { lstat, mkdir, open, readFile, readlink, rename, stat, unlink, writeFile } from "fs/promises";
import { dirname, join, parse, resolve, sep } from "path";

export async function resolveMutationTargetPath(path: string): Promise<string> {
    const absolutePath = resolve(path);
    const { root } = parse(absolutePath);
    const parts = absolutePath
        .slice(root.length)
        .split(sep)
        .filter((part) => part.length > 0);
    const visitedSymlinks = new Set<string>();

    async function resolveFromParts(currentPath: string, remainingParts: string[]): Promise<string> {
        if (remainingParts.length === 0) {
            return currentPath;
        }

        const [nextPart, ...tail] = remainingParts;
        const candidatePath = join(currentPath, nextPart);

        try {
            const candidateStats = await lstat(candidatePath);
            if (!candidateStats.isSymbolicLink()) {
                return resolveFromParts(candidatePath, tail);
            }

            if (visitedSymlinks.has(candidatePath)) {
                const error = new Error(`Too many symbolic links while resolving ${path}`) as NodeJS.ErrnoException;
                error.code = "ELOOP";
                throw error;
            }
            visitedSymlinks.add(candidatePath);

            const linkTargetPath = resolve(dirname(candidatePath), await readlink(candidatePath));
            const targetParts = linkTargetPath
                .slice(parse(linkTargetPath).root.length)
                .split(sep)
                .filter((part) => part.length > 0);
            return resolveFromParts(parse(linkTargetPath).root, [...targetParts, ...tail]);
        } catch (error: unknown) {
            if ((error as NodeJS.ErrnoException)?.code === "ENOENT") {
                return join(candidatePath, ...tail);
            }
            throw error;
        }
    }

    return resolveFromParts(root, parts);
}

async function assertExpectedContent(path: string, expectedContent: string | undefined): Promise<void> {
    if (expectedContent === undefined) return;
    let currentContent: string | null;
    try {
        currentContent = await readFile(path, "utf-8");
    } catch (error: unknown) {
        if ((error as NodeJS.ErrnoException)?.code !== "ENOENT") throw error;
        currentContent = null;
    }
    if (currentContent !== expectedContent) {
        throw new Error(
            `[E_FILE_CHANGED] File changed after it was read. Re-read before retrying; no changes were written.`,
        );
    }
}

export async function writeFileAtomically(
    path: string,
    content: string,
    options?: { alreadyResolved?: true; expectedContent?: string },
): Promise<void> {
    const targetPath = options?.alreadyResolved ? path : await resolveMutationTargetPath(path);
    let existingStats: Awaited<ReturnType<typeof stat>> | null = null;
    try {
        existingStats = await stat(targetPath);
    } catch (error: unknown) {
        if ((error as NodeJS.ErrnoException)?.code !== "ENOENT") {
            throw error;
        }
    }
    if (existingStats && existingStats.nlink > 1) {
        // Hard-linked files cannot be atomically replaced without breaking inode
        // sharing, so preserve links by updating existing inode in place.
        await assertExpectedContent(targetPath, options?.expectedContent);
        await writeFile(targetPath, content, "utf-8");
        return;
    }
    const dir = dirname(targetPath);
    const tempPath = join(dir, `.tmp-${randomUUID()}`);
    await mkdir(dir, { recursive: true });
    const tempHandle = await open(tempPath, "wx", 0o600);
    try {
        await tempHandle.writeFile(content, "utf-8");
        if (existingStats) {
            await tempHandle.chmod(existingStats.mode & 0o7777);
        }
        await tempHandle.close();
        // ponytail: external writes can race after this check; stronger safety needs cooperating writers/locks.
        await assertExpectedContent(targetPath, options?.expectedContent);
        await rename(tempPath, targetPath);
    } catch (error: unknown) {
        await tempHandle.close().catch(() => undefined);
        await unlink(tempPath).catch(() => undefined);
        throw error;
    }
}
