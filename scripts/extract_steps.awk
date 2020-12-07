#!/usr/local/bin/gawk -f

/^\/\/ step / {
  # sub(/^\/\/ step */, "")
  stepline=$0
  if (match(stepline, "^// step "step"$" ) != 0) {
    print("```groovy")
    printf("// Step - %s\n", step)
  }
}

/^$/ {
  next;
}

!/^\/\/ step / {
  line=$0
  if (match(stepline, "^// step "step"$" ) != 0) {
    printf("%s\n", line)
  }
}

END{print("```\n")}
