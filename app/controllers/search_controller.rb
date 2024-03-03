class SearchController < ApplicationController
  def index
    search_term = params[:query]
    @results = PgSearch.multisearch(search_term)
  end

  def linker
    player_one = params[:player_one]
    player_two = params[:player_two]

    p params.inspect
    return unless player_one && player_two

    player_one_class = PgSearch.multisearch(params[:player_one]).first.searchable_type
    player_one_id = PgSearch.multisearch(params[:player_one]).first.searchable_id
    node_1 = player_one_class.constantize.find(player_one_id)
    player_two_class = PgSearch.multisearch(params[:player_two]).first.searchable_type
    player_two_id = PgSearch.multisearch(params[:player_two]).first.searchable_id
    node_2 = player_two_class.constantize.find(player_two_id)

    linker_instance = NodeLinker.new(node_1, node_2)

    @shortest_path = linker_instance.summarize_links
  end
end
