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

alias BitSet = SparseBitSet::BitSet

module Graph::Data

  # A collection of associations represents an in-memory two-or-higher-mode
  # graph.  Each instance holds a set of many-to-many relationships between
  # heterogeneous vertices.  For each vertex, an adjacency list of related
  # vertices is maintained.
  #
  # Since vertices are represented by their unique IDs, a sparse bitset is
  # used to compactly store the adjacency lists.
  struct Associations(U, V)
    include Enumerable(Association(U, V))

    def initialize
      @map = Hash(UInt64, Association(U, V)).new()
      @forward_adj = Hash(UInt64, BitSet).new()
      @reverse_adj = Hash(UInt64, BitSet).new()
    end

    private def ids_hash(id1, id2 : UInt64) : UInt64
      id1 * 100_000 + id2
    end

    # add creates an association between the given elements, and stores it for
    # downstream computations.
    #
    # This method is idempotent.
    def add(origin, dest : UInt64, reference : String) : Bool
      a = Association(U, V).new(origin, dest, reference)
      h = ids_hash(origin, dest)

      return false if @map.has_key?(h)
      @map[h] = a

      bs = @forward_adj[origin]?
      bs = BitSet.new() unless bs
      bs.set(dest)
      @forward_adj[origin] = bs

      bs = @reverse_adj[dest]?
      bs = BitSet.new() unless bs
      bs.set(origin)
      @reverse_adj[dest] = bs

      true
    end

    # delete_origin deletes the references to the given origin in the
    # adjacency lists of its neighbours, and then deletes the element
    # itself.
    #
    # This method is idempotent.
    def delete_origin(oid : UInt64) : Bool
      l = @forward_adj[oid]?
      return false unless l

      iter = l.each
      while (did = iter.next) != Iterator::Stop::INSTANCE
        did = did as UInt64
        h = ids_hash(oid, did)
        @map.delete(h)

        bsd = @reverse_adj[did]
        bsd.clear(oid)
        @reverse_adj[did] = bsd
      end

      @forward_adj.delete(oid)
      true
    end

    # delete_dest deletes the references to the given destination in
    # the adjacency lists of its neighbours, and then deletes the
    # element itself.
    #
    # This method is idempotent.
    def delete_dest(did : UInt64) : Bool
      l = @reverse_adj[did]?
      return false unless l

      iter = l.each
      while (oid = iter.next) != Iterator::Stop::INSTANCE
        oid = oid as UInt64
        h = ids_hash(oid, did)
        @map.delete(h)

        bso = @forward_adj[oid]
        bso.clear(did)
        @forward_adj[oid] = bso
      end

      @reverse_adj.delete(did)
      true
    end

    # dests_for answers a bitset with destinations of associations of
    # the given origin.
    def dests_for(oid : UInt64) : BitSet | Nil
      bsd = @forward_adj[oid]?
      return nil unless bsd

      bsd.clone()
    end

    # origins_for answers a bitset with origins of associations of the
    # given destination.
    def origins_for(did : UInt64) : BitSet | Nil
      bso = @reverse_adj[did]?
      return nil unless bso

      bso.clone()
    end

    # dests_size_for answers the number of destinations of
    # associations of the given origin.
    def dests_size_for(oid : UInt64) : UInt64 | Nil
      bsd = @forward_adj[oid]?
      return nil unless bsd

      bsd.size
    end

    # origins_size_for answers the number of origins of associations
    # of the given destination.
    def origins_size_for(did : UInt64) : UInt64 | Nil
      bso = @reverse_adj[did]?
      return nil unless bso

      bso.size
    end

    # related? answers `true` if an association between the given
    # elements is registered; `false` otherwise.
    def related?(oid, did : UInt64) : Bool
      h = ids_hash(oid, did)
      @map.has_key?(h)
    end

    # size answers the number of registered associations.
    def size : UInt64
      @map.size.to_u64
    end

    # each implements the `Enumerable` interface.
    def each
      @map.each do |_, el|
        yield el
      end
    end
  end

  # InverseAssociations is an inverted, read-only view of a given set
  # of underlying associations.
  struct InverseAssociations(U, V)
    include Enumerable(Association(U, V))

    def initialize(@assocs : Associations(V, U))
      # Intentionally left blank.
    end

    # dests_for answers a bitset with destinations of associations of
    # the given origin.
    def dests_for(oid : UInt64) : BitSet | Nil
      @assocs.origins_for(oid)
    end

    # origins_for answers a bitset with destinations of associations
    # of the given destination.
    def origins_for(did : UInt64) : BitSet | Nil
      @assocs.dests_for(did)
    end

    # dests_size_for answers the number of destinations of
    # associations of the given origin.
    def dests_size_for(oid : UInt64) : UInt64 | Nil
      @assocs.dests_size_for(oid)
    end

    # origins_size_for answers the number of origins of associations
    # of the given destination.
    def origins_size_for(did : UInt64) : UInt64 | Nil
      @assocs.origins_size_for(did)
    end

    # related? answers `true` if an association between the given
    # elements is registered; `false` otherwise.
    def related?(oid, did : UInt64) : Bool
      @assocs.related?(did, oid)
    end

    # size answers the number of registered associations.
    def size : UInt64
      @assocs.size
    end

    # each implements the `Enumerable` interface.
    def each
      @assocs.each do |el|
        yield InverseAssociation(V, U).new(el)
      end
    end
  end

end
