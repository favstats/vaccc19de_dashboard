
last_update <- read_lines("last_update.txt")
current <- read_lines("current.txt")

if(last_update != current){

  unlink("docs", recursive = T, force = T)

  rmarkdown::render_site("site")
  rmarkdown::render("README.Rmd")
  file.remove("README.html")

  dir.create("docs")
  R.utils::copyDirectory("site/_site/", "docs")

  unlink("site/_site", recursive = T, force = T)

}
# system("git add -A")
# system(glue::glue('git commit -m "{Sys.time()}: Update Dashboard"'))
# system("git push")


