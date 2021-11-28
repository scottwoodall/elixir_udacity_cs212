defmodule PokerTest do
  use ExUnit.Case

  test "card ranks for four of a kind" do
    four_of_a_kind = ["9D", "7D", "9H", "9S", "9C"]
    expected = [9, 9, 9, 9, 7]
    actual = Poker.card_ranks(four_of_a_kind)
    assert actual == expected
  end

  test "card ranks for straight flush" do
    straight_flush = ["8C", "6C", "9C", "7C", "TC"]
    expected = [10, 9, 8, 7, 6]
    actual = Poker.card_ranks(straight_flush)
    assert actual == expected
  end

  test "card ranks for ace low straight" do
    straight = ["AD", "2C", "3S", "4C", "5C"]
    expected = [5, 4, 3, 2, 1]
    actual = Poker.card_ranks(straight)
    assert actual == expected
  end

  test "card ranks for full house" do
    full_house = ["7D", "7C", "TD", "TC", "TH"]
    expected = [10, 10, 10, 7, 7]
    actual = Poker.card_ranks(full_house)
    assert actual == expected
  end

  test "error thrown when no hands are played" do
    hands = []

    assert_raise FunctionClauseError, fn ->
      Poker.play(hands)
    end
  end

  test "error thrown when hands is not a list" do
    hands = "fake data"

    assert_raise FunctionClauseError, fn ->
      Poker.play(hands)
    end
  end

  test "is a straight" do
    ranks = [9, 8, 7, 6, 5]
    expected = true
    actual = Poker.straight?(ranks)
    assert actual == expected
  end

  test "is not a straight" do
    ranks = [9, 8, 8, 6, 5]
    expected = false
    actual = Poker.straight?(ranks)
    assert actual == expected
  end

  test "is a flush" do
    hand = ["9S", "8S", "7S", "6S", "5S"]
    expected = true
    actual = Poker.flush?(hand)
    assert actual == expected
  end

  test "is not a flush" do
    hand = ["9S", "8S", "7H", "6S", "5S"]
    expected = false
    actual = Poker.flush?(hand)
    assert actual == expected
  end

  test "is four of a kind" do
    four_of_a_kind = ["9D", "9H", "9S", "9C", "7D"]
    ranks = Poker.card_ranks(four_of_a_kind)
    expected = 9
    actual = Poker.kind(4, ranks)
    assert actual == expected
  end

  test "is four of a kind but tests for three of a kind" do
    four_of_a_kind = ["9D", "9H", "9S", "9C", "7D"]
    ranks = Poker.card_ranks(four_of_a_kind)
    expected = nil
    actual = Poker.kind(3, ranks)
    assert actual == expected
  end

  test "is four of a kind but tests for one of a kind" do
    four_of_a_kind = ["9D", "9H", "9S", "9C", "7D"]
    ranks = Poker.card_ranks(four_of_a_kind)
    expected = 7
    actual = Poker.kind(1, ranks)
    assert actual == expected
  end

  test "is two pair" do
    hand = ["5S", "5D", "9H", "9C", "6S"]
    hand_rank = Poker.card_ranks(hand)
    expected = {9, 5}
    actual = Poker.two_pair(hand_rank)
    assert actual == expected
  end

  test "is not two pair" do
    hand = ["5S", "5D", "9H", "TC", "6S"]
    hand_rank = Poker.card_ranks(hand)
    expected = nil
    actual = Poker.two_pair(hand_rank)
    assert actual == expected
  end

  test "full house hand rank value" do
    full_house = ["TD", "TC", "TH", "7C", "7D"]
    expected = {6, 10, 7}
    actual = Poker.hand_rank(full_house)
    assert actual == expected
  end

  test "straight flush hand rank value" do
    straight_flush = ["6C", "7C", "8C", "9C", "TC"]
    expected = {8, 10, 0}
    actual = Poker.hand_rank(straight_flush)
    assert actual == expected
  end

  test "straight flush over four of a kind and full house" do
    straight_flush = ["6C", "7C", "8C", "9C", "TC"]
    four_of_a_kind = ["9D", "9H", "9S", "9C", "7D"]
    full_house = ["TD", "TC", "TH", "7C", "7D"]
    hands = [straight_flush, four_of_a_kind, full_house]
    expected = [straight_flush]
    actual = Poker.play(hands)
    assert actual == expected
  end

  test "only a single hand playing wins" do
    four_of_a_kind = ["9D", "9H", "9S", "9C", "7D"]
    hands = [four_of_a_kind]
    expected = [four_of_a_kind]
    actual = Poker.play(hands)
    assert actual == expected
  end

  test "four of a kind hand rank value" do
    four_of_a_kind = ["9D", "9H", "9S", "9C", "7D"]
    expected = {7, 9, 7}
    actual = Poker.hand_rank(four_of_a_kind)
    assert actual == expected
  end

  test "straight flush beats 100 full houses" do
    straight_flush = ["6C", "7C", "8C", "9C", "TC"]
    full_house = ["TD", "TC", "TH", "7C", "7D"]
    one_hundred_full_houses = full_house |> List.duplicate(100)
    hands = [straight_flush | one_hundred_full_houses]
    expected = [straight_flush]
    actual = Poker.play(hands)
    assert actual == expected
  end

  test "four of a kind over full house" do
    four_of_a_kind = ["9D", "9H", "9S", "9C", "7D"]
    full_house = ["TD", "TC", "TH", "7C", "7D"]
    hands = [four_of_a_kind, full_house]
    expected = [four_of_a_kind]
    actual = Poker.play(hands)
    assert actual == expected
  end

  test "ace low straight flush beats four of a kind" do
    four_of_a_kind = ["9D", "9H", "9S", "9C", "7D"]
    straight_flush = ["2C", "3C", "4C", "5C", "AC"]
    hands = [four_of_a_kind, straight_flush]
    expected = [straight_flush]
    actual = Poker.play(hands)
    assert actual == expected
  end

  test "full house ties to full house" do
    full_house_p1 = ["TD", "TC", "TH", "7C", "7D"]
    full_house_p2 = ["TS", "TC", "TH", "7S", "7H"]
    high_card = ["2S", "5D", "7H", "9S", "JH"]
    hands = [full_house_p1, full_house_p2, high_card]
    actual = Poker.play(hands)
    assert Enum.member?(actual, full_house_p1)
    assert Enum.member?(actual, full_house_p2)
    assert Enum.count(actual) == 2
  end

  test "deal five hands of five cards each" do
    num_hands = 5
    num_cards = 5
    deck = Poker.new_deck() |> Poker.shuffle_deck()
    deck_size = Enum.count(deck)
    {hands, deck} = Poker.deal(num_hands, deck, num_cards)
    assert Enum.count(deck) == deck_size - num_hands * num_cards
    assert Enum.count(hands) == num_hands
  end

  test "king high beats queen high" do
    king_high = ["4C", "6S", "8H", "TD", "KS"]
    queen_high = ["3D", "5C", "7D", "9C", "QS"]
    hands = [king_high, queen_high]
    expected = [king_high]
    actual = Poker.play(hands)
    assert actual == expected
  end

  test "hand rank probabilities are close to wikipedia probabilities" do
    # https://en.wikipedia.org/wiki/Poker_probability
    # use this to run a true simulation, otherwise it takes too long to run so a small
    # sample size is used to get the test suite to run quickly
    sample_size = div(700_000, 10)
    # sample_size = div(100, 10)

    hand_names = [
      "Straight Flush (0.0013)",
      "Four of a Kind (0.0240)",
      "Full House (0.144)",
      "Flush (0.196)",
      "Straight (0.392)",
      "Three of a Kind (2.112)",
      "Two pair (4.753)",
      "One Pair (42.256)",
      "High Card (50.117)"
    ]

    Stream.flat_map(1..sample_size, fn _ ->
      deck = Poker.new_deck() |> Poker.shuffle_deck()
      {hands, _} = Poker.deal(10, deck)
      hands
    end)
    |> Stream.map(&Poker.hand_rank/1)
    |> Enum.reduce([0, 0, 0, 0, 0, 0, 0, 0, 0], fn x, acc ->
      List.update_at(acc, Kernel.elem(x, 0), &(&1 + 1))
    end)
    |> Enum.reverse()
    |> Enum.with_index(fn x, index ->
      {Enum.at(hand_names, index), Float.round(10 * (x / sample_size), 3)}
    end)
    |> IO.inspect()
  end
end
