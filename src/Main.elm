module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as JD



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { urls : List String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model [], getAuthUrls )



-- UPDATE


type Msg
    = GotAuthUrls (Result Http.Error (List String))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotAuthUrls result ->
            case result of
                Ok urls ->
                    let
                        _ =
                            Debug.log "urls" urls
                    in
                    ( { model | urls = urls }, Cmd.none )

                Err e ->
                    let
                        _ =
                            Debug.log "error" e
                    in
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "App"
    , body =
        [ h1 [] [ text "App Login" ]
        , ul [] <| List.map (\u -> showUrl u) model.urls
        ]
    }


showUrl : String -> Html Msg
showUrl url =
    li [] [ a [ href url ] [ text url ] ]


getAuthUrls : Cmd Msg
getAuthUrls =
    Http.get
        { url = "https://appapispike.herokuapp.com/api/auth/urls"
        , expect = Http.expectJson GotAuthUrls authUrlsDecoder
        }


authUrlsDecoder : JD.Decoder (List String)
authUrlsDecoder =
    JD.field "data" (JD.list urlDecoder)


urlDecoder : JD.Decoder String
urlDecoder =
    JD.field "url" JD.string
