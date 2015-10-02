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

  # Default initial size for masters.
  INIT_MASTER_SIZE = 256_u64

  class Master(T)
    include Enumerable(T)

    # Constructs a master for the given entity type, having the given initial
    # capacity.
    def initialize(n = INIT_MASTER_SIZE : UInt64)
      @ary = Array(T).new(n)
      @map = Hash(String, T).new()

      @excluded = SparseBitSet::BitSet.new()
    end

    # entity nswers the entity type of this master.
    def entity : String
      T.name
    end

    # add creates a new instance with the given data, and registers it in this
    # master in the case of no collision.  An internal unique ID is assigned
    # to the instance.
    #
    # This method is idempotent.
    def add(name, provider, provider_id : String) : Bool
      raise ArgumentError.new("empty name") if name.empty?
      raise ArgumentError.new("empty provider") if provider.empty?
      raise ArgumentError.new("empty provider_id") if provider_id.empty?
      return false if @map.has_key?(provider_id)

      id = (@ary.size + 1).to_u64
      t = T.new(id, name, provider, provider_id)
      @ary << t
      @map[provider_id] = t
      true
    end

    # exclude marks the element with the given ID to be excluded from
    # downstream computations.
    #
    # This method is idempotent.
    def exclude(id : UInt64) : Bool
      return false if id < 1 || id > @ary.size

      @excluded.set(id)
      true
    end

    # [] answers the element with the given ID, if one such exists; `nil`
    # otherwise.
    def [](id : UInt64) : T | Nil
      return nil if id < 1 || id > @ary.size
      return nil if @excluded.test(id)

      @ary[id-1]
    end

    # [] answers the element with the given provider ID, if one such exists;
    # `nil` otherwise.
    def [](pid : String) : T | Nil
      el = @map[pid]?
      return nil unless el
      return nil if @excluded.test(el.id)

      el
    end

    # size answers the number of registered elements in this master.
    def size : UInt64
      @ary.size.to_u64 - @excluded.size
    end

    # each implements the `Enumerable` interface requirement.
    def each
      @ary.each { |el| yield el }
    end
  end

end
