require "../graph_spec"

alias Stat = Graph::Lib::Stat

describe "p-value calculation" do
  t = Stat.chi_square_2x2(c_11: 180_u64, c_12: 90_u64, c_21: 60_u64, c_22: 170_u64)

  it "checks chi-square value" do
    ((t[0] - 81.93).abs < 0.01).should eq(true)
  end

  it "checks p-value" do
    t[1].should eq(0.001)
  end

  it "checks reliability" do
    t[2].should eq(true)
  end

  t = Stat.chi_square_2x2(c_11: 20_u64, c_12: 30_u64, c_21: 30_u64, c_22: 20_u64)

  it "checks chi-square value" do
    ((t[0] - 4.0).abs < 0.01).should eq(true)
  end

  it "checks p-value" do
    t[1].should eq(0.05)
  end

  it "checks reliability" do
    t[2].should eq(true)
  end
end
