module Cards
  module Search
    def self.by_keyword(project_id, raw_keyword)
      keyword = Regexp.escape raw_keyword.strip
      search_phrase = "%#{keyword}%"
      items = cards_scope(project_id).where { cards_cards.name =~ my { search_phrase } }
        
      Cards.collection_to_open_structs(items)
    end
    
    def from_title_versions
      @project.stories.joins { versions.outer }.
        where { versions.name =~ my { @pattern } }.
        where { cards_cards.mark_as_deleted == false }.
        group { id }.
        order { updated_at.desc }
    end

    def from_description_versions
      @project.stories.joins { versions.outer }.
        where { versions.description =~ my { @pattern } }.
        where { cards_cards.mark_as_deleted == false }.
        group { id }.
        order { updated_at.desc }
    end

    def from_tags
      @project.stories.joins { taggings.outer.tag.outer }.
        where { cards_tags.name =~ my { @pattern } }.
        where { cards_cards.mark_as_deleted == false }.
        group { id }.
        order { updated_at.desc }
    end
    
    private

    def self.tag_scope
      Models::Tag.joins(:taggings).where("cards_taggings.card_id = cards_cards.id").select("ARRAY_AGG(name ORDER BY name)")
    end

    def self.cards_scope(project_id)
      Models::Card.where(project_id: project_id)
        .select("cards_cards.*")
        .select("COALESCE((#{tag_scope.to_sql}), '{}') AS tag_names")
        .where { cards_cards.mark_as_deleted == false }
        .group { id }
        .order { cards_cards.updated_at.desc }
    end
  end  
end
