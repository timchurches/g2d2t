library(ggplot2)

easy_labs <- function(...) { 

  lp <- last_plot()
  if (!is.null(attr(lp, "easy_labs"))) lp$labels <- lp$orig_labels
  
  ## extract old labels from plot under construction
  old_labels <- lp$labels
  old_label_names <- names(old_labels)
  
  ## strip formatting of any labels
  old_labels <- sub("^.*\\(+", "", old_labels, perl = TRUE)
  old_labels <- sub("\\)+.*$", "", old_labels, perl = TRUE)

  ## take new labels from variable labels
  if (!inherits(lp$data, "waiver")) {
    new_labels <- labelled::var_label(lp$data[, unlist(old_labels)])
  } else {
    new_labels <- as.list(old_labels)
  }
  
  ## replace any which don't have a label with the original aesthetic
  names(new_labels) <- old_label_names
  new_labels[sapply(new_labels, is.null)] <- old_labels[sapply(new_labels, is.null)]
  
  ## any labels in additional layers?
  n_layers <- length(lp$layers)
  if (n_layers > 0) {
    layer_labels <- lapply(seq_len(n_layers), function(x) {
      l <- lp$layers[[x]]
      if (!inherits(l$data, "waiver")) {
        old_l_labels <- labelled::var_label(l$data)
        old_mapping <- sapply(l$mapping, as.character)
        new_l_labels <- old_l_labels[unname(old_mapping)]
        names(new_l_labels) <- names(old_mapping)
        return(new_l_labels)
      } else {
        return(NULL)
      }
    })

    ## add the layer labels
    if (!inherits(lp$data, "waiver")) {
      new_labels <- modifyList(new_labels, layer_labels)
    } else {
      new_labels <- modifyList(new_labels, layer_labels[[1]])
    }
    
  }
  ## create a list of class 'labels' and return
  arg_labels <- do.call(list, new_labels)
  new_struct <- structure(arg_labels, class = "easy_labs")
  
  return(new_struct)
  
}

ggplot_add.easy_labs <- function(object, plot, object_name) {
  class(object) <- "labels"
  plot$orig_labels <- plot$labels
  plot$labels <- object
  attr(plot, "easy_labs") <- TRUE
  plot
}

mtcars2 <- mtcars
labelled::var_label(mtcars2$cyl) <- "Cylinders"
labelled::var_label(mtcars2$mpg) <- "Miles Per Gallon"
labelled::var_label(mtcars2$hp) <- "Horsepower"

## works with labels
ggplot(data=mtcars2, aes(x=hp, y=mpg)) + geom_point() + easy_labs()
## facetting works fine
ggplot(mtcars2, aes(hp, mpg)) + geom_point() + facet_wrap(~cyl) + easy_labs()
## missing labels get their aesthetic instead
ggplot(mtcars2, aes(disp, mpg)) + geom_point() + facet_wrap(~cyl) + easy_labs()

iris1 <- iris
labelled::var_label(iris1$Sepal.Length) <- "Length of sepal"
labelled::var_label(iris1$Sepal.Width) <- "Width of sepal"
labelled::var_label(iris1$Species) <- "Original Species Label"
iris2 <- iris1
iris2$Species <- as.character(iris2$Species)
iris2[iris2$Species=="setosa",]$Species <- "rainbow"
labelled::var_label(iris2$Species) <- "Sub-genera"
iris3 <- iris1
labelled::var_label(iris3$Species) <- "Another Label"

labelled::var_label(iris1)
labelled::var_label(iris2)
labelled::var_label(iris3)

## adding geoms with labels works fine
ggplot(data=iris1, aes(x=Sepal.Length, y=Sepal.Width, fill = Species)) + 
  geom_point(data=iris2, aes(colour = Species), size = 2) + 
  geom_point(data=iris3, aes(shape = Species)) + 
  # facet_wrap(~Species) +
  easy_labs()

p <- ggplot(mtcars2, aes(hp, mpg)) + geom_point() 
p + easy_labs()
## extract the label from a transformed column
p + geom_point(aes(shape = factor(cyl))) + easy_labs()
## data only provided in geom
ggplot() + geom_point(data = mtcars2, aes(hp, mpg)) + easy_labs()
