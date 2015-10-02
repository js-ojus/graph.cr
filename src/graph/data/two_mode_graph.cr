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

require "sparsebitset"

module Graph::Data

  # ClustCoefficients is a simple data holder for the normal, minimum
  # and maximum clustering coefficients of a pair of vertices.
  struct ClustCoefficients
    def initialize(@normal_cc, @min_cc, @max_cc : Float64)
      # Intentionally left blank.
    end

    getter normal_cc, min_cc, max_cc
  end

  # TwoModeGraph represents relationships between elements from two
  # sets, and their properties.
  #
  # While the properties and measures herein are written primarily for
  # two mode graphs (i.e. relationships r: A --> B, A =/= B), some of
  # them apply equally to one mode graphs as well.  A knowledgeable
  # user can utilise the same appropriately.
  struct TwoModeGraph(U, V)
    def initialize(@origins : Master(U), @dests : Master(V), @assocs : Associations(U, V))
      # Intentionally left blank.
    end

    # clust_coefficients answers the normal, minimum and maximum
    # clustering coefficients for the given origin pair.
    def clust_coefficients(oid1, oid2 : UInt64) : ClustCoefficients | Nil
      bs1 = @assocs.dests_for(oid1)
      return nil unless bs1
      bs2 = @assocs.dests_for(oid2)
      return nil unless bs2

      clust_coefficients(oid1, oid2, bs1, bs1.size, bs2, bs2.size)
    end

    # clust_coefficients answers the normal, minimum and maximum
    # clustering coefficients for the given origin pair.
    #
    # This method allows efficiency in inner loops by taking the
    # destinations for the first origin - and their count - as
    # parameters.
    def clust_coefficients(oid1, oid2 : UInt64, bs1 : BitSet, size1 : UInt64) : ClustCoefficients | Nil
      bs2 = @assocs.dests_for(oid2)
      return nil unless bs2

      clust_coefficients(oid1, oid2, bs1, size1, bs2, bs2.size)
    end

    # clust_coefficients answers the normal, minimum and maximum
    # clustering coefficients for the given origin pair.
    #
    # This method allows efficiency in inner loops by taking the
    # destinations for the origins - and their counts - as parameters.
    def clust_coefficients(oid1, oid2 : UInt64, bs1 : BitSet, size1 : UInt64, bs2 : BitSet, size2 : UInt64) : ClustCoefficients
      bs_12_i = bs1.intersection(bs2)
      bs_12_u = bs1.union(bs2)
      size_12_i = bs_12_i.size.to_f64
      size_12_u = bs_12_u.size.to_f64

      small = (size1 < size2) ? size1.to_f64 : size2.to_f64
      normal_cc = size_12_i / size_12_u
      min_cc = size_12_i / small
      max_cc = size_12_i / small

      ClustCoefficients.new(normal_cc, min_cc, max_cc)
    end
  end

end
