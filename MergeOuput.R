MergeOutput <- function(name = "combined_plots") {
  "Merges all PNG plots from the working directory into a single PDF file, with a table of contents and supertitles on each page"
  library(gridExtra)
  library(png)

  # Specify the folder containing the PNGs (adjust to your folder)
  png_files <- list.files(path = ".", pattern = "\\.png$", full.names = TRUE)

  # Check if PNG files exist
  if (length(png_files) == 0) {
    stop("No PNG files found in the folder!")
  }

  # Create a PDF file to store all the plots
  output_pdf <- paste0(name, ".pdf")
  pdf(output_pdf, width = 8, height = 6) # Set PDF dimensions

  # Add Table of Contents (TOC) page
  grid::grid.newpage()
  grid::grid.text("Table of Contents",
    y = 0.95,
    gp = grid::gpar(fontsize = 20, fontface = "bold")
  )
  for (i in seq_along(png_files)) {
    png_name <- tools::file_path_sans_ext(basename(png_files[i]))
    grid::grid.text(paste(i, png_name, "- Page", i + 1),
      y = 0.9 - 0.05 * i,
      gp = grid::gpar(fontsize = 12)
    )
  }
  grid::grid.newpage()

  # Loop through PNGs and add them to the PDF
  for (i in seq_along(png_files)) {
    file <- png_files[i]
    png_name <- tools::file_path_sans_ext(basename(file))
    cat("Merging PNG:", file, "\n")
    img <- png::readPNG(file)

    grid::grid.raster(img)
    grid::grid.text(png_name,
      y = 0.94,
      gp = grid::gpar(fontsize = 16, fontface = "bold")
    ) # adding supertitle
    grid::grid.text(i + 1,
      y = 0.05,
      gp = grid::gpar(fontsize = 10, fontface = "italic")
    ) # adding page numbering

    if (i < length(png_files)) grid::grid.newpage()
  }
  # Close the PDF device
  dev.off()

  cat("PDF created successfully:", output_pdf, "\n")
}
