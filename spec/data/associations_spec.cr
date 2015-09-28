require "../graph_spec"
require "./entity_spec"

alias Association = Graph::Data::Association
alias Associations = Graph::Data::Associations

describe "new" do
  it "checks empty" do
    as = Associations(Drug, AdverseEffect).new()
    as.size.should eq(0)
  end
end

describe "association registration" do
  it "zero origin ID" do
    as = Associations(Drug, AdverseEffect).new()
    begin
      as.add(0_u64, 1_u64, "cite")
    rescue
      true
    else
      false
    end
  end

  it "empty reference" do
    as = Associations(Drug, AdverseEffect).new()
    begin
      as.add(1_u64, 2_u64, "")
    rescue
      true
    else
      false
    end
  end
end

describe "association existence" do
  it "checks existence" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    as.related?(1_u64, 2_u64)
  end
end

describe "association lists" do
  it "checks destinations" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    set = as.dests_for(1_u64)
    set.nil?.should eq(false)
  end

  it "checks destinations" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    set = as.dests_for(1_u64)
    if set
      set.size.should eq(1_u64)
    else
      false
    end
  end

  it "checks destinations" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    as.add(1_u64, 3_u64, "citation-2")
    set = as.dests_for(1_u64)
    if set
      set.test(3_u64)
    else
      false
    end
  end

  it "checks origins" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    as.add(1_u64, 3_u64, "citation-2")
    set = as.origins_for(2_u64)
    if set
      set.test(1_u64)
    else
      false
    end
  end
end

describe "association deletion" do
  it "deletes origins" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    as.add(1_u64, 3_u64, "citation-2")
    as.delete_origin(1_u64)
    as.size.should eq(0_u64)
  end

  it "deletes origins" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    as.add(1_u64, 3_u64, "citation-2")
    as.add(2_u64, 3_u64, "citation-2")
    as.delete_origin(1_u64)
    as.size.should eq(1_u64)
  end

  it "deletes destinations" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    as.add(1_u64, 3_u64, "citation-2")
    as.delete_dest(2_u64)
    as.size.should eq(1_u64)
  end

  it "deletes destinations" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    as.add(1_u64, 3_u64, "citation-2")
    as.add(2_u64, 3_u64, "citation-2")
    as.delete_dest(3_u64)
    as.size.should eq(1_u64)
  end

  it "deletes destinations" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    as.add(1_u64, 3_u64, "citation-2")
    as.add(2_u64, 3_u64, "citation-2")
    as.delete_dest(2_u64)
    as.delete_dest(3_u64)
    as.size.should eq(0_u64)
  end
end

describe "iteration" do
  it "checks iteration" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    as.add(1_u64, 3_u64, "citation-2")
    as.add(2_u64, 3_u64, "citation-2")

    ary = [] of Association(Disease, Pathway)
    as.each do |el|
      ary << el
    end
    ary.size.should eq(3)
  end

  it "checks iteration" do
    as = Associations(Disease, Pathway).new()
    as.add(1_u64, 2_u64, "citation-1")
    as.add(2_u64, 3_u64, "citation-2")

    ary = [] of Association(Disease, Pathway)
    as.each do |el|
      ary << el
    end
    ary[1].origin.should eq(2_u64)
  end
end
