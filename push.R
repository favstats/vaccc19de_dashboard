

while(T){
  unlink("docs")

  rmarkdown::render_site()

  Sys.sleep(1)

  system("mv _site docs")

  system("git add -A")
  system(glue::glue('git commit -m "{Sys.time()}: Update Dashboard"'))
  system("git push")

  Sys.sleep(60*60*24)
}


