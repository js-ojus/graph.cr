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

  # A collection of associations represents an in-memory two-or-higher-mode
  # graph.  Each instance holds a set of many-to-many relationships between
  # heterogeneous vertices.  For each vertex, an adjacency list of related
  # vertices is maintained.
  #
  # Since vertices are represented by their unique IDs, a sparse bitset is
  # used to compactly store the adjacency lists.
  struct Associations(U, V)
    def initialize
      @map = Hash(UInt64, Association).new()
      @forward_adj = Hash(UInt64, SparseBitSet::BitSet).new()
      @reverse_adj = Hash(UInt64, SparseBitSet::BitSet).new()
    end

    # add creates an association between the given elements, and stores it for
    # downstream computations.
    #
    # This method is idempotent.
    def add(origin : UInt64, dest : UInt64, reference : String) : Bool
      a = Association(U, V).new(origin, dest, reference)
      h = origin * 100_000 + dest

      return false if @map.has_key?(h)
      @map[h] = a

      if (bs = @forward_adj[origin]?).nil?
        bs = SparseBitSet::BitSet.new()
      end
      bs.set(dest)
      @forward_adj[origin] = bs

      if (bs = @reverse_adj[dest]?).nil?
        bs = SparseBitSet::BitSet.new()
      end
      bs.set(origin)
      @reverse_adj[dest] = bs

      true
    end
  end

end
