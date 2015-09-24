require "../../pharm_spec"

alias Master = Pharm::DrugRepos::Common::Master
alias Drug = Pharm::DrugRepos::Common::Drug
alias AdverseEffect = Pharm::DrugRepos::Common::AdverseEffect

describe "new" do
  it "checks entity" do
    m = Master(Drug).new()
    m.entity.should eq("Pharm::DrugRepos::Common::Drug")
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
