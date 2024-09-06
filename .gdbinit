define printqs5static
  set $d=$arg0.d
  printf "(Qt5 QString)0x%x length=%i: \"",&$arg0,$d->size
  set $i=0
  set $ca=(const ushort*)(((const char*)$d)+$d->offset)
  while $i < $d->size
    set $c=$ca[$i++]
    if $c < 32 || $c > 127
      printf "\\u%04x", $c
    else
      printf "%c" , (char)$c
    end
  end
  printf "\"\n"
end

define printqs5dynamic
  set $d=(QStringData*)$arg0.d
  printf "(Qt5 QString)0x%x length=%i: \"",&$arg0,$d->size
  set $i=0
  while $i < $d->size
    set $c=$d->data()[$i++]
    if $c < 32 || $c > 127
      printf "\\u%04x", $c
    else
      printf "%c" , (char)$c
    end
  end
  printf "\"\n"
end

set history save on

python
class AddSymbolFileAuto (gdb.Command):
    def __init__(self):
        super(AddSymbolFileAuto, self).__init__("add-symbol-file-auto", gdb.COMMAND_USER)

    def invoke(self, solibpath, from_tty):
        offset = self.get_text_offset(solibpath)
        gdb_cmd = "add-symbol-file %s %s" % (solibpath, offset)
        gdb.execute(gdb_cmd, from_tty)

    def get_text_offset(self, solibpath):
        import subprocess
        # Note: Replace "readelf" with path to binary if it is not in your PATH.
        elfres = subprocess.check_output(["readelf", "-WS", solibpath])
        for line in elfres.splitlines():
            if "] .text " in line:
                return "0x" + line.split()[4]
        return ""  # TODO: Raise error when offset is not found?
AddSymbolFileAuto()
end

set pagination off

set debuginfod enabled off
# set debuginfod enabled on

# Disable thread-events (i.e. New Thread... & Thread ... exited messages)
set print thread-events off
