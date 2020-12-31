

while(T){
  rmarkdown::render("dashboard.Rmd", output_file = "index.html")

  system("git add -A")
  system(glue::glue('git commit -m "{Sys.time()}: Update Dashboard"'))
  system("git push")

  Sys.sleep(60*60*24)
}


