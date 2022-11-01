# shellcheck disable=SC2148

setopt APPEND_HISTORY         # append to history file
setopt CORRECT                # Try to correct the spelling of commands.
setopt HIST_EXPIRE_DUPS_FIRST # Expire a duplicate event first when trimming history.
setopt HIST_FIND_NO_DUPS      # Do not display a previously found event.
setopt HIST_IGNORE_DUPS       # Do not record an event that was just recorded again.
setopt HIST_IGNORE_SPACE      # Do not record an event starting with a space.
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
setopt INC_APPEND_HISTORY     # Write to the history file immediately, not when the shell exits.
setopt NO_CASE_GLOB           # Make  globbing  (filename  generation) insensitive to case.
setopt SHARE_HISTORY          # Share history between all sessions.

# setopt CORRECT_ALL            # Try to correct the spelling of all arguments in a line.
