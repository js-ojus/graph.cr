# (c) Copyright 2015 JONNALAGADDA Srinivas
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

module Graph::Lib::Stat
  extend self

  # sensitivity answers how sensitive two variables are w.r.t. each
  # the other.
  #
  # The counts of true positives and false negatives are required for
  # this computation.  A 2x2 contingency table that counts frequencies
  # should be constructed to obtain the inputs.
  def sensitivity(tp = 0, fn = 0 : UInt64) : Float64
    tp.to_f64 / (tp.to_f64 + fn.to_f64)
  end

  # specificity answers how specific two variables are w.r.t. each the
  # other.
  #
  # The counts of true negatives and false positives are required for
  # this computation.  A 2x2 contingency table that counts frequencies
  # should be constructed to obtain the inputs.
  def specificity(tn = 0, fp = 0 : UInt64) : Float64
    tn.to_f64 / (tn.to_f64 + fp.to_f64)
  end

  # mcc answers the Matthews Correlation Coefficient (MCC) for the
  # contingency table between the two variables in question.
  #
  # A 2x2 contingency table that counts frequencies should be
  # constructed to obtain the inputs.  All the four cells are utilised
  # in this computation.
  def mcc(tp = 0, tn = 0, fp = 0, fn = 0 : UInt64) : Float64
    num = (tp * tn) - (fp * fn)
    denom = (tp + fp) * (tp + fn) * (tn + fp) * (tn + fn)
    num.to_f64 / Math.sqrt(denom.to_f64)
  end

  # Table of chi-square distribution for the first 10 degrees of freedom.
  #
  # Values taken from Wikipedia's article on chi-square distribution:
  # https://en.wikipedia.org/wiki/Chi-squared_distribution#Table_of_.CF.872_value_vs_p-value.
  CHI_SQUARES = [
    [0.004, 0.02, 0.06, 0.15, 0.46, 1.07, 1.64, 2.71, 3.84, 6.64, 10.83],
    [0.10, 0.21, 0.45, 0.71, 1.39, 2.41, 3.22, 4.60, 5.99, 9.21, 13.82],
    [0.35, 0.58, 1.01, 1.42, 2.37, 3.66, 4.64, 6.25, 7.82, 11.34, 16.27],
    [0.71, 1.06, 1.65, 2.20, 3.36, 4.88, 5.99, 7.78, 9.49, 13.28, 18.47],
    [1.14, 1.61, 2.34, 3.00, 4.35, 6.06, 7.29, 9.24, 11.07, 15.09, 20.52],
    [1.63, 2.20, 3.07, 3.83, 5.35, 7.23, 8.56, 10.64, 12.59, 16.81, 22.46],
    [2.17, 2.83, 3.82, 4.67, 6.35, 8.38, 9.80, 12.02, 14.07, 18.48, 24.32],
    [2.73, 3.49, 4.59, 5.53, 7.34, 9.52, 11.03, 13.36, 15.51, 20.09, 26.12],
    [3.32, 4.17, 5.38, 6.39, 8.34, 10.66, 12.24, 14.68, 16.92, 21.67, 27.88],
    [3.94, 4.86, 6.18, 7.27, 9.34, 11.78, 13.44, 15.99, 18.31, 23.21, 29.59],
  ]

  # p-value distribution from 5% confidence to 99.9% confidence.
  #
  # Values taken from Wikipedia's article on chi-square distribution:
  # https://en.wikipedia.org/wiki/Chi-squared_distribution#Table_of_.CF.872_value_vs_p-value.
  P_VALUES = [0.95, 0.90, 0.80, 0.70, 0.50, 0.30, 0.20, 0.10, 0.05, 0.01, 0.001]

  # chi_square_2x2 answers a tuple of three values: computed
  # chi-square value, looked-up p-value and a reliability indicator.
  # The latter indicator is `true` if **all** the computed expected
  # values are >= `5.0`; else it is `false`.
  def chi_square_2x2(c_11 = 0, c_12 = 0, c_21 = 0, c_22 = 0 : UInt64) : Tuple(Float64, Float64, Bool)
    row1_sum = (c_11 + c_12).to_f64
    row2_sum = (c_21 + c_22).to_f64
    col1_sum = (c_11 + c_21).to_f64
    col2_sum = (c_12 + c_22).to_f64
    total = row1_sum + row2_sum

    exp_c_11 = row1_sum * col1_sum / total
    exp_c_12 = row1_sum * col2_sum / total
    exp_c_21 = row2_sum * col1_sum / total
    exp_c_22 = row2_sum * col2_sum / total

    chi_square = ((c_11 - exp_c_11) ** 2) / exp_c_11 +
                 ((c_12 - exp_c_12) ** 2) / exp_c_12 +
                 ((c_21 - exp_c_21) ** 2) / exp_c_21 +
                 ((c_22 - exp_c_22) ** 2) / exp_c_22

    # Since the matrix is 2x2, effective degrees of freedom is
    # (2-1)*(2-1) = 1.  Index in the chi-square table is 0.
    idx = CHI_SQUARES[0].index { |el| el > chi_square }
    if idx
      # If the computed chi-square value is smaller than the very
      # first entry in the table, use the first entry in the p-value
      # table.  Otherwise, use the index of the largest entry in the
      # chi-square table that is smaller than the computed chi-square
      # value.
      p_value = (idx == 0) ? P_VALUES[0] : P_VALUES[idx-1]
    else
      # Computed chi-square value is larger than the largest entry in
      # the table.  That implies higher statistical confidence than
      # the last entry in the p-values table.
      p_value = 0.001
    end

    if exp_c_11 < 5.0 || exp_c_12 < 5.0 || exp_c_21 < 5.0 || exp_c_22 < 5.0
      return {chi_square, p_value, false}
    end

    {chi_square, p_value, true}
  end
end
