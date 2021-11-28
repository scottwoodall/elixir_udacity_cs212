defmodule Poker do
  @moduledoc """
  Documentation for `Poker`.
  """

  @doc """
  Return a list of winning hands: poker([hand, ...]) => [hand,...]
  """
  def play(hands) when is_list(hands) and length(hands) > 0 do
    allmax(hands)
  end

  def allmax(hands) do
    hands
    |> Enum.map(fn x ->
      rank = hand_rank(x)
      {x, rank}
    end)
    |> Enum.sort_by(
      fn x ->
        {_hand, rank} = x
        rank
      end,
      :desc
    )
    |> Enum.reduce_while([], fn x, acc ->
      {_, rank} = x

      {_, max_rank} =
        Enum.max_by(
          acc,
          fn x ->
            {_, sort_rank} = x
            sort_rank
          end,
          fn -> {[], {0, 0, 0}} end
        )

      cond do
        Enum.count(acc) == 0 or rank >= max_rank ->
          {:cont, [x | acc]}

        true ->
          {:halt, acc}
      end
    end)
    |> Enum.map(fn x ->
      {hand, _} = x
      hand
    end)
  end

  @doc """
  Returns an unshuffled 52 card deck
  """
  def new_deck() do
    ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
    suits = ["S", "H", "D", "C"]
    for r <- ranks, s <- suits, do: "#{r}#{s}"
  end

  @doc """
  Returns a shuffled version of the passed in deck
  """
  def shuffle_deck(deck) do
    Enum.shuffle(deck)
  end

  @doc """
  ["KC", "JS", "3S", "KS", "7S", "TD", "2H", "8H", "4C", "AD", "6H"]

  [
      ["KC", "JS", "3S", "KS", "7S"],
      ["TD", "2H", "8H", "4C", "AD", "6H"],
  ]
  """
  def deal(num_hands, deck, num_cards \\ 5, accumulator \\ [])

  def deal(num_hands, deck, num_cards, accumulator) when num_hands > 0 do
    accumulator = [Enum.slice(deck, 0, num_cards) | accumulator]
    deck = Enum.drop(deck, num_cards)
    deal(num_hands - 1, deck, num_cards, accumulator)
  end

  def deal(0, deck, _num_cards, accumulator) do
    {accumulator, deck}
  end

  @doc """
  Return a value indicating the ranking of a hand
  """
  def hand_rank(hand) do
    ranks = card_ranks(hand)

    cond do
      # straight flush
      straight?(ranks) and flush?(hand) ->
        {8, Enum.max(ranks), 0}

      # four of a kind
      kind?(4, ranks) ->
        {7, kind(4, ranks), kind(1, ranks)}

      # full house
      kind?(3, ranks) and kind?(2, ranks) ->
        {6, kind(3, ranks), kind(2, ranks)}

      # flush
      flush?(hand) ->
        {5, ranks, 0}

      # straight
      straight?(ranks) ->
        {4, Enum.max(ranks), 0}

      # three of a kind
      kind?(3, ranks) ->
        {3, kind(3, ranks), ranks}

      # two pair
      two_pair(ranks) ->
        {2, two_pair(ranks), ranks}

      # two of a kind
      kind(2, ranks) ->
        {1, kind(2, ranks), ranks}

      # highest card
      true ->
        {0, ranks, 0}
    end
  end

  def card_ranks(hand) do
    rankings = [nil, nil, "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]

    sorted =
      hand
      |> Enum.map(fn x ->
        card = String.first(x)
        Enum.find_index(rankings, fn x -> x == card end)
      end)
      |> Enum.sort(:desc)

    cond do
      # edge case where ace is used in low straight
      sorted == [14, 5, 4, 3, 2] ->
        [5, 4, 3, 2, 1]

      true ->
        sorted
    end
  end

  @doc """
  If there are two pair, return the two ranks as a tuple (highest, lowest);
  otherwise reuturn nil.
  """
  def two_pair(ranks) do
    pair = kind(2, ranks)
    low_pair = kind(2, Enum.reverse(ranks))

    if pair != nil and low_pair != pair do
      {pair, low_pair}
    else
      nil
    end
  end

  @doc """
  Return true if the ordered ranks form a 5-card straight
  """
  def straight?(ranks) do
    Enum.sort(ranks) == Enum.to_list(Enum.min(ranks)..Enum.max(ranks))
  end

  @doc """
  Return true if all the cards have the same suit
  """
  def flush?(hand) do
    cards = for card <- hand, do: String.last(card)
    suits = MapSet.new(cards)
    MapSet.size(suits) == 1
  end

  def kind(n, ranks) do
    frequencies = Enum.frequencies(ranks)
    kinds = Enum.map(ranks, fn x -> {x, Map.get(frequencies, x)} end)
    bro = Enum.filter(kinds, fn {_, value} -> value == n end)
    rank = List.first(bro, {nil, nil})
    Kernel.elem(rank, 0)
  end

  def kind?(n, ranks) do
    kind(n, ranks) != nil
  end

  def combinations(list, num)
  def combinations(_list, 0), do: [[]]
  def combinations(list = [], _num), do: list

  def combinations([head | tail], num) do
    Enum.map(combinations(tail, num - 1), &[head | &1]) ++ combinations(tail, num)
  end

  def best_possible_hand(hand) do
    combinations(hand, 5)
    |> play()
  end
end
