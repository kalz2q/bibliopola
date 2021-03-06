module Model.Book exposing
    ( currentPage
    , empty
    , frontCover
    , hasNoPage
    , isOpen
    , pages
    , routeQuery
    , selectedStory
    , setPages
    , setStories
    , shelfIsOpen
    , stories
    , storiesPage
    , title
    , toggle
    , toggleShelf
    , turn
    , withFrontCover
    )

import Dict exposing (Dict)
import Element exposing (Element)
import Route
import SelectList exposing (SelectList)
import Types exposing (..)


turn : List ( String, String ) -> Book -> Book
turn query (Book book) =
    let
        queryDict =
            Dict.fromList query
    in
    Book
        { book
            | isOpen =
                Dict.get "isOpen" queryDict
                    |> Maybe.andThen Route.toBool
                    |> Maybe.withDefault False
            , stories =
                List.map
                    (\( label, options ) ->
                        Dict.get label queryDict
                            |> Maybe.andThen
                                (\selected ->
                                    SelectList.selectHead options
                                        |> SelectList.selectAfterIf ((==) selected)
                                )
                            |> Maybe.map (Tuple.pair label)
                            |> Maybe.withDefault ( label, options )
                    )
                    book.stories
        }


routeQuery : Book -> List ( String, String )
routeQuery (Book book) =
    ( "isOpen", Route.fromBool book.isOpen )
        :: List.map (Tuple.mapSecond SelectList.selected) book.stories



-- Basics


empty : String -> Book
empty title_ =
    Book
        { title = title_
        , pages = Dict.empty
        , stories = []
        , isOpen = False
        , shelfIsOpen = False
        }


title : Book -> String
title (Book book) =
    book.title



-- Pages


pages : Book -> Dict String (Element Msg)
pages (Book book) =
    book.pages


hasNoPage : Book -> Bool
hasNoPage book =
    pages book
        |> Dict.isEmpty


setPages : Dict String (Element Msg) -> Book -> Book
setPages newPages (Book book) =
    Book { book | pages = newPages }


currentPage : Book -> Maybe (Element Msg)
currentPage book =
    if isOpen book then
        storiesPage book

    else
        frontCover book


storiesPage : Book -> Maybe (Element Msg)
storiesPage book =
    Dict.get
        (selectedStory book
            |> List.map Tuple.second
            |> String.join "/"
        )
        (pages book)


frontCover : Book -> Maybe (Element Msg)
frontCover book =
    Dict.get "frontCover" (pages book)


withFrontCover : Element String -> Book -> Book
withFrontCover view book =
    let
        pages_ =
            pages book
                |> Dict.insert "frontCover" (Element.map LogMsg view)
    in
    setPages pages_ book



-- Stories


stories : Book -> List ( String, SelectList String )
stories (Book book) =
    book.stories


setStories : List ( String, SelectList String ) -> Book -> Book
setStories newStories (Book book) =
    Book { book | stories = newStories }


selectedStory : Book -> List ( String, String )
selectedStory book =
    stories book
        |> List.map (Tuple.mapSecond SelectList.selected)



-- Others


shelfIsOpen : Book -> Bool
shelfIsOpen (Book book) =
    book.shelfIsOpen


toggleShelf : Book -> Book
toggleShelf (Book book) =
    Book { book | shelfIsOpen = not book.shelfIsOpen }


isOpen : Book -> Bool
isOpen (Book book) =
    book.isOpen


toggle : Book -> Book
toggle (Book book) =
    Book { book | isOpen = not book.isOpen }
