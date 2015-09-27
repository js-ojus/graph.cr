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

module Graph::Data

  # Given two vertices of types `U` and `V`, where `U` != `V`, an instance of
  # `Association` represents an edge connecting them.  The graph is at least
  # two-mode.
  struct Association(U, V)
    # Creates an association between the two given heterogeneous vertices.
    def initialize(@origin : UInt64, @dest : UInt64, @reference : String)
      raise ArgumentError.new("zero ID") if @origin == 0 || @dest == 0
      raise ArgumentError.new("empty reference citation") if @reference.empty?
    end

    getter :origin, :dest, :reference
  end

  # Given an association between elements of types `U` and `V`, this presents
  # an inverse association origin `V` to `U`.  This is NOT a data holder by
  # itself; it is only a view!
  struct InverseAssociation(U, V)
    # Creates an inverse association of the given association.
    def initialize(@assoc : Association(U, V))
      # Intentionally left blank.
    end

    # origin answers the `dest` of the underlying association.
    def origin : UInt64
      @assoc.dest
    end

    # dest answers the `origin` of the underlying association.
    def dest : UInt64
      @assoc.origin
    end

    # reference answers the information in the underlying association.
    def reference : String
      @assoc.reference
    end
  end

  # InferredAssociation represents a synthetic edge between a pair of
  # heterogeneous vertices.  Those parts of the graph that are formed from
  # input associations, are used to infer these transitive relationships.
  struct InferredAssociation(U, V) < Association(U, V)
    def initialize(origin : UInt64, dest : UInt64, reference : String,
                   @specificity : Float64, # how specific is this element of `U` to that of `V`
                   @sensitivity : Float64, # how sensitive is this element of `U` to variations in that of `V`
                   @mcc : Float64,         # Matthews Correlation Coefficient
                   @chi_square : Float64,  # indication of the strength of this association
                   @p_value : Float64,     # statistical significance
                   @reliable : Bool        # is the computed p-value reliable?
                  )
      super(origin, dest, reference)
    end

    getter specificity, sensitivity, mcc, chi_square, p_value

    def reliable? : Bool
      @reliable
    end
  end

end
