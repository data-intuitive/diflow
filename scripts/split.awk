#!/bin/awk

BEGIN {
  level1=""
  level2=""
  level3=""
  l1_index=0
  l2_index=0
  process_l1=0
  process_l2=0
  filename="extra"
}

/^# / {
  sub(/^# /, "")
  level1=$0
  filename=dir l1_index ".md"
  print filename
  print "---" > filename
  print "title: "level1 > filename
  print "has_children: true" > filename
  print "nav_order: " l1_index > filename
  print "---" > filename
  print "" > filename
  print "# " level1 > filename
  l1_index++
  l2_index=0
  process_l1=1
  process_l2=0
  next
}

/^## / {
  sub(/^## /, "")
  level2=$0
  filename=dir l1_index "-" l2_index ".md"
  print filename
  print "---" > filename
  print "title: " level2 > filename
  print "parent: " level1> filename
  print "nav_order: " l2_index > filename
  print "---" > filename
  print "" > filename
  print "## " level2 > filename
  l2_index++
  process_l1=0
  process_l2=1
  next
}

!/^# / || !/^## / {
  print > filename
}
