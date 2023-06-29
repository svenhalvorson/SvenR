# Having this reocurring problem where binding data sets together vertically
# causes some of the labels to flip out. GUess we can write this function to
# copy labels that I thought of like a year ago:
copy_labels = function(to, from){

  if(
    any(
      !is.data.frame(to),
      !is.data.frame(from)
    )
  ){
    stop('errors in copy_labels, write more of them later')
  }

  colnames_intersect = intersect(colnames(to), colnames(from))

  for(column in colnames_intersect){

    if(haven::is.labelled(from[[column]])){

      to[[column]] = haven::labelled(
        x = to[[column]],
        label = attr(from[[column]], 'label'),
        labels = attr(from[[column]], 'labels')
      )
    }

  }

  to
}
