
# Sys.sleep(60*60*18)

while(T){
  unlink("docs", recursive = T, force = T)
  unlink("site/_site", recursive = T, force = T)

  rmarkdown::render_site()

  dir.create("docs")
  R.utils::copyDirectory("site/_site/", "docs")

  system("git add -A")
  system(glue::glue('git commit -m "{Sys.time()}: Update Dashboard"'))
  system("git push")

  Sys.sleep(60*60*24)
}


