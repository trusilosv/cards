module Cards
  module Search
    def self.by_keyword(project_id, raw_keyword)
      keyword = Regexp.escape raw_keyword.strip
      search_phrase = "%#{keyword}%"
      items = Models::CardVersion.select("cards_card_versions.card_id as id, cards_card_versions.name, cards_card_versions.description, cards_card_versions.version")
        .select("matched_versions.current")
        .joins("JOIN (#{card_versions_scope(project_id, search_phrase).to_sql}) AS matched_versions ON matched_versions.card_id = cards_card_versions.card_id AND matched_versions.version = cards_card_versions.version ")
        .order{ updated_at.desc }
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

    def self.card_versions_scope(project_id, search_phrase)
      Models::CardVersion.where{ cards_cards.project_id == project_id }
        .select("cards_cards.id as card_id")
        .select("MAX(cards_card_versions.version) AS version")
        .select("(MAX(cards_card_versions.version) = cards_cards.version) AS current")
        .where { cards_cards.mark_as_deleted == false }
        .where { (cards_card_versions.name =~ my { search_phrase }) | (cards_card_versions.description =~ my { search_phrase } ) }
        .joins(:card)
        .group("cards_cards.id")
    end
  end
end
