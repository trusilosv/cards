module Cards
  module Search
    def self.by_keyword(project_id, raw_keyword)
      keyword = Regexp.escape raw_keyword.strip
      search_phrase = "%#{keyword}%"
      items = Models::CardVersion.select("cards_card_versions.card_id as id, cards_card_versions.name, cards_card_versions.description, cards_card_versions.version")
        .select("COALESCE((#{tag_scope.to_sql}), '{}') AS tag_names")
        .select("matched_versions.current")
        .joins("JOIN (#{card_versions_scope(project_id, search_phrase).to_sql}) AS matched_versions ON matched_versions.card_id = cards_card_versions.card_id AND matched_versions.version = cards_card_versions.version ")
        .order( <<-SQL
          (case
          when cards_card_versions.name ilike '#{search_phrase}' then 1 when cards_card_versions.description ilike '#{search_phrase}' then 2 else 3 end)
        SQL
        )
        .order{ [matched_versions.current.desc, cards_card_versions.updated_at.desc] }
      Cards.collection_to_open_structs(items)
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
      Models::Tag.joins(:taggings).where("cards_taggings.card_id = cards_card_versions.card_id").select("ARRAY_AGG(name ORDER BY name)")
    end

    def self.card_versions_scope(project_id, search_phrase)
      Models::CardVersion.where{ cards_cards.project_id == project_id }
        .select("cards_cards.id as card_id")
        .select("MAX(cards_card_versions.version) AS version")
        .select("(MAX(cards_card_versions.version) = cards_cards.version) AS current")
        .joins(:card)
        .joins(<<-SQL
          LEFT JOIN cards_taggings ON cards_taggings.card_id = cards_card_versions.card_id
          LEFT JOIN cards_tags ON cards_taggings.tag_id = cards_tags.id
        SQL
        )
        .where { cards_cards.mark_as_deleted == false }
        .where {
          (cards_card_versions.name =~ my { search_phrase }) |
          (cards_card_versions.description =~ my { search_phrase } ) |
          (cards_tags.name =~ my { search_phrase } )
        }
        .group("cards_cards.id")
    end
  end
end
