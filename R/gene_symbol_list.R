>   x <- org.Hs.egSYMBOL
>     # Get the gene symbol that are mapped to an entrez gene identifiers
>     mapped_genes <- mappedkeys(x)
>     # Convert to a list
>     xx <- as.list(x[mapped_genes])
>     if(length(xx) > 0) {
+       # Get the SYMBOL for the first five genes
+       xx[1:5]
+       # Get the first one
+       xx[[1]]
+     }
