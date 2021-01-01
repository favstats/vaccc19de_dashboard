
# Sys.sleep(60*60*18)

while(T){
  unlink("docs", recursive = T, force = T)
  unlink("_site", recursive = T, force = T)

  rmarkdown::render_site()

  R.utils::copyDirectory("_site/", "docs")

  unlink("_site", recursive = T, force = T)

  system("git add -A")
  system(glue::glue('git commit -m "{Sys.time()}: Update Dashboard"'))
  system("git push")

  Sys.sleep(60*60*24)
}


