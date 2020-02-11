module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as JD
import Url



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Page
    = Home
    | Login


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model key Home, Cmd.none )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotAuthUrls (Result Http.Error (List String))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked link ->
            case link of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( model, Cmd.none )

        GotAuthUrls result ->
            case result of
                Ok urls ->
                    ( model, Cmd.none )

                Err e ->
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
        ]
    }


getAuthUrls : Cmd Msg
getAuthUrls =
    Http.get
        { url = "http://localhost:4000/api/auth/urls"
        , expect = Http.expectJson GotAuthUrls authUrlsDecoder
        }


authUrlsDecoder : JD.Decoder (List String)
authUrlsDecoder =
    JD.field "data" (JD.list urlDecoder)


urlDecoder : JD.Decoder String
urlDecoder =
    JD.field "url" JD.string
