imgur_dir=`dirname "$(readlink -f "$0")"`
imgur_script="$imgur_dir/imgur.sh/imgur.sh"

# Imgur
# Usage: imgur [filename]
imgur() {
  $imgur_script "$@"
}
