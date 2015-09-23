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

module Pharm::DrugRepos::Common

  # Entity defines the basic data elements that are common to all
  # entities (but not associations.)
  #
  # The numerical ID is used for all internal look-up purposes, while
  # `provider_id` is used for user-initiated look-ups.  Accordingly, it has to
  # be globally-unique.
  macro def_entity(name)
    class {{ name.id }}
      def initialize(@id : UInt64, @name : String, @provider : String, @provider_id : String)
        raise ArgumentError.new("zero ID") if @id == 0
        raise ArgumentError.new("empty name") if @name.empty?
        raise ArgumentError.new("empty provider") if @provider.empty?
        raise ArgumentError.new("empty provider ID") if @provider_id.empty?
      end

      getter id, name, provider, provider_id
    end
  end

  # AdverseEffect represents an unwanted side effect caused by a
  # particular drug.  Adverse effects form part of a controlled
  # vocabulary.
  def_entity :AdverseEffect

  # Disease represents a disease condition.  It acts as one of the
  # major hubs in the graph.  It is an intermediate layer in
  # transitive relationships between targets, drugs, pathways, adverse
  # effects, etc.
  def_entity :Disease

  # Drug represents either a clinical drug, or a pre-clinical,
  # depending on the context.  It acts as one of the major hubs in the
  # graph.  It is an intermediate layer in transitive relationships
  # between targets, diseases, pathways, adverse effects, etc.
  def_entity :Drug

  # Pathway represents a biochemical pathway in an organism.  It may
  # involve multiple targets that can be acted upon by drugs.
  def_entity :Pathway

  # Target represents a biological gene that can either participate in
  # a pathway, or affect one, or be a target of one or more drug
  # molecules.
  def_entity :Target

end
