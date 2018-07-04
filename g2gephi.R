#------------------------------------------------------
# Part of InstaCrawlR
# GitHub: https://github.com/JonasSchroeder/InstaCrawlR
# See ReadME for instructions and examples
#
# Source: https://gopalakrishna.palem.in/iGraphExport.html
# Creator: Gopalakrishna Palem
# Modified by Jonas Schröder
# Converts the given igraph object to GEXF format and saves it at the given filepath location
#     g: input igraph object to be converted to gexf format
#     filepath: file location where the output gexf file should be saved
#-------------------------------------------------------

library(igraph)
library(rgexf)

saveAsGEXF = function(g, filepath="converted_graph.gexf")
{
    require(igraph)
    require(rgexf)
    
    # gexf nodes require two column data frame (id, label)
    # check if the input vertices has label already present
    # if not, just have the ids themselves as the label
    if(is.null(V(g)$label)){
        V(g)$label <- as.character(V(g))   
    }
    
    # similarily if edges does not have weight, add default 1 weight
    if(is.null(E(g)$weight)){
        E(g)$weight <- rep.int(1, ecount(g)) 
    }
    
    nodes <- data.frame(cbind(V(g), V(g)$label))
    edges <- t(Vectorize(get.edge, vectorize.args='id')(g, 1:ecount(g)))
    
    # combine all node attributes into a matrix (and take care of & for xml)
    vAttrNames <- setdiff(list.vertex.attributes(g), "label") 
    nodesAtt <- data.frame(sapply(vAttrNames, function(attr) sub("&", "&",get.vertex.attribute(g, attr))))
    
    # combine all edge attributes into a matrix (and take care of & for xml)
    eAttrNames <- setdiff(list.edge.attributes(g), "weight") 
    edgesAtt <- data.frame(sapply(eAttrNames, function(attr) sub("&", "&",get.edge.attribute(g, attr))))
    
    # combine all graph attributes into a meta-data
    graphAtt <- sapply(list.graph.attributes(g), function(attr) sub("&", "&",get.graph.attribute(g, attr)))
    
    # generate the gexf object
    output <- write.gexf(nodes, edges, 
                         edgesWeight=E(g)$weight,
                         edgesAtt = edgesAtt,
                         nodesAtt = nodesAtt,
                         meta=c(list(creator="Gopalakrishna Palem, modified by Jonas Schröder", description="igraph -> gexf converted file", keywords="igraph, gexf, R, rgexf"), graphAtt))
    
    sink("gexf-HASHTAG.gexf")
    print(output, filepath, replace=T)
    sink()
}

#Run the export
saveAsGEXF(graph3)
