module Cards
  module Search
    def self.by_keyword(project_id, raw_keyword)
      keyword = Regexp.escape raw_keyword.strip
      search_phrase = "%#{keyword}%"
      version_items = Models::CardVersion.select("cards_card_versions.card_id as id, cards_card_versions.name, cards_card_versions.description, cards_card_versions.version, cards_card_versions.author_id")
        .select("COALESCE((#{tag_scope('cards_card_versions.card_id').to_sql}), '{}') AS tag_names")
        .select("matched_versions.current")
        .joins("JOIN (#{card_versions_scope(project_id, search_phrase).to_sql}) AS matched_versions ON matched_versions.card_id = cards_card_versions.card_id AND matched_versions.version = cards_card_versions.version ")
        .order(order_clase_by_versions(search_phrase))
        .order{ [matched_versions.current.desc, cards_card_versions.updated_at.desc] }
        .index_by(&:id)
      tag_items = search_in_tags_scope(project_id, search_phrase).index_by(&:id)
      items = version_items.merge(tag_items).values
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

    def self.tag_scope(card_id_sql)
      Models::Tag.joins(:taggings).where("cards_taggings.card_id = #{card_id_sql}").select("ARRAY_AGG(name ORDER BY name)")
    end

    def self.search_in_tags_scope(project_id, search_phrase)
      Models::Card.select("cards_cards.id, cards_cards.name, cards_cards.description, cards_cards.version, cards_cards.author_id")
        .select("COALESCE((#{tag_scope('cards_cards.id').to_sql}), '{}') AS tag_names")
        .select("'t'::boolean AS current")
        .joins(<<-SQL
          LEFT JOIN cards_taggings ON cards_taggings.card_id = cards_cards.id
          LEFT JOIN cards_tags ON cards_taggings.tag_id = cards_tags.id
        SQL
        )
        .where(project_id: project_id)
        .where { (cards_tags.name =~ my { search_phrase }) }
        .group("cards_cards.id")
        .order{ cards_cards.updated_at.desc }
    end

    def self.card_versions_scope(project_id, search_phrase)
      Models::CardVersion.where{ cards_cards.project_id == project_id }
        .select("cards_cards.id as card_id")
        .select("MAX(cards_card_versions.version) AS version")
        .select("(MAX(cards_card_versions.version) = cards_cards.version) AS current")
        .joins(:card)
        .where { cards_cards.mark_as_deleted == false }
        .where {
          (cards_card_versions.name =~ my { search_phrase }) |
          (cards_card_versions.description =~ my { search_phrase } )
        }
        .group("cards_cards.id")
    end

    def self.order_clase_by_versions(search_phrase)
      versions_table = Models::CardVersion.arel_table
      Arel::Nodes::SqlLiteral.new <<-SQL
        (CASE
          WHEN #{versions_table[:name].matches(search_phrase).to_sql} THEN 1
          WHEN #{versions_table[:description].matches(search_phrase).to_sql} THEN 2
          ELSE 3
        END)
      SQL
    end
  end
end
