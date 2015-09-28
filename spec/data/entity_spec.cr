require "../graph_spec"

# AdverseEffect represents an unwanted side effect caused by a
# particular drug.  Adverse effects form part of a controlled
# vocabulary.
Graph::Data.def_entity :AdverseEffect

# Disease represents a disease condition.  It acts as one of the
# major hubs in the graph.  It is an intermediate layer in
# transitive relationships between targets, drugs, pathways, adverse
# effects, etc.
Graph::Data.def_entity :Disease

# Drug represents either a clinical drug, or a pre-clinical,
# depending on the context.  It acts as one of the major hubs in the
# graph.  It is an intermediate layer in transitive relationships
# between targets, diseases, pathways, adverse effects, etc.
Graph::Data.def_entity :Drug

# Pathway represents a biochemical pathway in an organism.  It may
# involve multiple targets that can be acted upon by drugs.
Graph::Data.def_entity :Pathway

# Target represents a biological gene that can either participate in
# a pathway, or affect one, or be a target of one or more drug
# molecules.
Graph::Data.def_entity :Target
