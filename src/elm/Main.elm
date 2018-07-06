module Main exposing (..)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class, classList)
import Random


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Group
    = A
    | B


type alias Card =
    { id : String
    , group : Group
    , flipped : Bool
    }


type alias Deck =
    List Card


type Model
    = Playing Deck


type Msg
    = NoOp
    | Shuffle (List Int)


cards : List String
cards =
    [ "amy"
    , "bender"
    , "fry"
    , "leela"
    , "hubert"
    , "hermes"
    , "zoidberg"
    , "mom"
    ]


initCard : Group -> String -> Card
initCard group name =
    { id = name
    , group = group
    , flipped = False
    }


deck : Deck
deck =
    let
        groupA =
            List.map (initCard A) cards

        groupB =
            List.map (initCard B) cards
    in
    List.concat [ groupA, groupB ]


cardClass : Card -> String
cardClass card =
    "card-" ++ card.id


createCard : Card -> Html Msg
createCard card =
    div [ class "container" ]
        -- try changing ("flipped", False) into ("flipped", True)
        [ div [ classList [ ( "card", True ), ( "flipped", True ) ] ]
            [ div [ class "card-back" ] []
            , div [ class ("front " ++ cardClass card) ] []
            ]
        ]


randomList : (List Int -> Msg) -> Int -> Cmd Msg
randomList msg len =
    Random.int 0 100
        |> Random.list len
        |> Random.generate msg


shuffleDeck : Deck -> List comparable -> Deck
shuffleDeck deck xs =
    List.map2 (,) deck xs
        |> List.sortBy Tuple.second
        |> List.unzip
        |> Tuple.first


init : ( Model, Cmd Msg )
init =
    let
        model =
            Playing deck

        cmd =
            randomList Shuffle (List.length deck)
    in
    ( model, cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- a ! b is equivalent to (a, Cmd.batch b)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        Shuffle xs ->
            let
                newDeck =
                    shuffleDeck deck xs
            in
            Playing newDeck ! []


view : Model -> Html Msg
view model =
    case model of
        Playing deck ->
            div [ class "wrapper" ] (List.map createCard deck)
