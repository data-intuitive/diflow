#!/usr/local/bin/gawk -f

BEGIN {
  idx=0
  prev_line=""
  start_code=0
}

/^# / {
  header=$0
  if (match(header, /^# Step by step/) != 0) {
    process=1
    print("# Step by step")
    print("- - -")
    print("")
  } else {
    process=0
    # print("don't process this header")
  }
}

# Stop processing at step 25, this is a dedicated topic
/^## Step 25/ {
  sub(/^## /, "")
  title=$0
  process=0
  next
}

/^## / {
  sub(/^## /, "")
  title=$0
  if (process == 1) {
    print("## "title)
    print("")
    print("- - -")
    print("")
  }
}

/^``` \{sh/ {
  start_code=1
  next
}

/^awk / {
  cli=$0
  if (process == 1 && start_code == 1) {
    print("")
    print("``` {sh eval=TRUE, echo=FALSE, results=\"asis\"}")
    print(cli)
    print("```")
    print("")
    print("- - -")
    print("")
  }
  start_code=0
  next
}

/cat/ || /nextflow/ && !/awk/ {
  if (process == 1 && start_code == 1) {
    cli=$0
    # Just use the idx pointing to the proper base64-encoded cast file
    # if (idx == 0) {
      base64 = ""
      base64_file = "../casts/" idx ".cast.base64"
      getline base64 < base64_file
      close(base53_file)
      # base64=system("cat casts/" idx ".base64 | tr -d '\n'")
      print("<asciinema-player font-size='medium' preload='preload' src='data:application/json;base64," base64 "'></asciinema-player>")
      print("")
      print("- - -")
      print("")
    # }
    start_code=0
    idx++
  }
}

/^```groovy/ {
  line=$0
  if (process == 1) {
    copy_line=1
    print("")
    print(line)
  }
  next
}

/^```$/ {
  line=$0
  if (process == 1 && copy_line == 1) {
    print(line)
    print("")
    copy_line=0
  }
}

/.*/ {
  line=$0
  if (process == 1 && copy_line == 1) {
    print(line)
  }
}

