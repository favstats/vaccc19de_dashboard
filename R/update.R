
unlink("docs", recursive = T, force = T)

rmarkdown::render_site("site")
rmarkdown::render("README.Rmd", output_file = "README.md")

dir.create("docs")
R.utils::copyDirectory("site/_site/", "docs")

unlink("site/_site", recursive = T, force = T)

# system("git add -A")
# system(glue::glue('git commit -m "{Sys.time()}: Update Dashboard"'))
# system("git push")


