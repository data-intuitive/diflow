#!/usr/local/bin/gawk -f

BEGIN {
  # An index to identify code blocks
  idx=0
  start_code=0
}

/^## / {
  sub(/^## /, "")
  title=$0
  if (process == 1) {
    print("### "title)
    print("")
  }
}

/^``` \{sh/ {
  start_code=1
  next
}

/cat/ || /nextflow/ && !/awk/ {
  if (start_code == 1) {
    cli=$0
    sub(/-q/, "")
    shorter_cli=$0
    print("Running " shorter_cli)
    print("idx " idx)
    # Just use the idx pointing to the proper base64-encoded cast file
    # if (idx == 0) {
      full_cli="echo Running: " shorter_cli "\necho ---\n" shorter_cli "\necho ---\n"
      asciinema_cli = "asciinema rec --overwrite casts/" idx ".cast -c '" full_cli "'"
      print(shorter_cli)
      # base64_cli = "base64 -i casts/" idx ".cast -o casts/" idx ".base64"
      # print(base64_cli)
      asciinema_output = system(asciinema_cli)
      # base64_output = system(base64_cli)
      print(asciinema_output)
      # print(base64_output)

    # }
    start_code=0
    idx++
  }
}

/^awk/ {
  if (start_code == 1) {
    start_code=0
  }
}

