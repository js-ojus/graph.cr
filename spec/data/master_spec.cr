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

alias Master = Graph::Data::Master

describe "new" do
  it "checks entity" do
    m = Master(Drug).new()
    m.entity.should eq("Drug")
  end

  it "checks size" do
    m = Master(Drug).new()
    m.size.should eq(0_u64)
  end
end

describe "data registration" do
  it "registers drug" do
    m = Master(Drug).new()
    m.add("abacavir", "CAS", "136470-78-5")
    m.size.should eq(1_u64)
  end

  it "registers drug" do
    m = Master(Drug).new()
    m.add("abacavir", "CAS", "136470-78-5")
    el = m[1_u64]
    if el
      el.name.should eq("abacavir")
    else
      false
    end
  end

  it "registers drug" do
    m = Master(Drug).new()
    m.add("abacavir", "CAS", "136470-78-5")
    el = m[42_u64]
    el.should eq(nil)
  end

  it "registers adverse effect" do
    m = Master(AdverseEffect).new()
    m.add("hyperglycemia", "UMLS", "C0020456")
    m.size.should eq(1_u64)
  end

  it "registers adverse effect" do
    m = Master(AdverseEffect).new()
    m.add("hyperglycemia", "UMLS", "C0020456")
    el = m["C0020456"]
    if el
      el.name.should eq("hyperglycemia")
    else
      false
    end
  end

  it "registers adverse effect" do
    m = Master(AdverseEffect).new()
    m.add("hyperglycemia", "UMLS", "C0020456")
    el = m["C0020455"]
    el.should eq(nil)
  end
end

describe "data exclusion" do
  it "checks exclusion" do
    m = Master(Drug).new()
    m.add("abacavir", "CAS", "136470-78-5")
    m.exclude(1_u64)
    m.size.should eq(0_u64)
  end

  it "checks exclusion" do
    m = Master(Drug).new()
    m.add("abacavir", "CAS", "136470-78-5")
    m.add("acamprosate", "CAS", "77337-76-9")
    m.exclude(1_u64)
    m.size.should eq(1_u64)
  end

  it "checks exclusion" do
    m = Master(Drug).new()
    m.add("abacavir", "CAS", "136470-78-5")
    m.add("acamprosate", "CAS", "77337-76-9")
    m.exclude(1_u64)
    el = m[2_u64]
    if el
      el.name.should eq("acamprosate")
    else
      false
    end
  end
end

describe "iteration" do
  it "checks iteration" do
    m = Master(Drug).new()
    m.add("abacavir", "CAS", "136470-78-5")
    m.add("acamprosate", "CAS", "77337-76-9")

    ary = [] of Drug
    m.each do |el|
      ary << el
    end
    ary.size.should eq(2)
  end
end
