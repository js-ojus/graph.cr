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

module Graph::Lib

  # TwoModeNullHypothesis evaluates two samples of a variate against a
  # fixed one of another.  Under the null hypothesis, the two samples
  # should behave similarly.
  #
  # The pair being compared is of type `U`.  The element providing
  # context for comparison is of type `V`.  Frequencies are counted
  # using associations of elements of types `U` and `V` with those of
  # type `W`.
  class TwoModeNullHypothesis(U, V, W)
    def initialize(@uv_assocs : Associations(U, V), @uw_assocs : Associations(U, W), @vw_assocs : Associations(V, W))
      # Intentionally left blank.
    end

    # test_null_hypothesis computes a contingency table involving the
    # given pair of elements of `U` with respect to the given element
    # of `V`.  If the null hypothesis is true, the pair of `U` should
    # not exhibit a statistically significant difference in their
    # behaviour.
    def test_null_hypothesis(uid1, uid2 : UInt64, vid : UInt64) : Tuple(Float64, Float64, Bool)
      # If at least one `U` element is not already known to be
      # directly related to the given `V` element, this test is
      # useless.
      known_us = @uv_assocs.origins_for(vid)
      return {0.0, 0.0, false} unless known_us
      return {0.0, 0.0, false} unless known_us.test(uid1) || known_us.test(uid2)

      uid1_ws = @uw_assocs.dests_for(uid1)
      uid2_ws = @uw_assocs.dests_for(uid2)
      vid_ws  = @vw_assocs.dests_for(vid)
      return {0.0, 0.0, false} unless uid1_ws && uid2_ws && vid_ws

      # If the two `U` elements have no `W` associations in common,
      # this test cannot be carried out.
      tp = uid1_ws.intersection(uid2_ws)
      return {0.0, 0.0, false} if tp.empty?

      # Compute the other cells.
      fp = uid1_ws.difference(uid2_ws)
      fn = uid2_ws.difference(uid1_ws)
      tn = vid_ws.difference(uid1_ws)
      tn = tn.difference(uid2_ws)

      # Compute chi-square and p-value.
      GenStat.chi_square_2x2(tp.size, fp.size, fn.size, tn.size)
    end
  end

end
