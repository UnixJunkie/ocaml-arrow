open Core_kernel
open Arrow_c_api

let%expect_test _ =
  let t =
    List.init 12 ~f:(fun i ->
        let cols =
          [ Wrapper.Writer.utf8 [| "v1"; "v2"; "v3" |] ~name:"foo"
          ; Wrapper.Writer.utf8_opt
              [| None; Some (sprintf "hello %d" i); Some "world" |]
              ~name:"foobar"
          ; Wrapper.Writer.int [| i; i + 1; 2 * i |] ~name:"baz"
          ; Wrapper.Writer.int_opt [| Some (i / 2); None; None |] ~name:"baz_opt"
          ]
        in
        Wrapper.Writer.create_table ~cols)
    |> Wrapper.Table.concatenate
  in
  print_s ~mach:() ([%sexp_of: Column.t] (Column.experimental_fast_read t 0));
  print_s ~mach:() ([%sexp_of: Column.t] (Column.experimental_fast_read t 1));
  print_s ~mach:() ([%sexp_of: Column.t] (Column.experimental_fast_read t 2));
  print_s ~mach:() ([%sexp_of: Column.t] (Column.experimental_fast_read t 3));
  [%expect
    {|
    (String(v1 v2 v3 v1 v2 v3 v1 v2 v3 v1 v2 v3 v1 v2 v3 v1 v2 v3 v1 v2 v3 v1 v2 v3 v1 v2 v3 v1 v2 v3 v1 v2 v3 v1 v2 v3))
    (String_option(()("hello 0")(world)()("hello 1")(world)()("hello 2")(world)()("hello 3")(world)()("hello 4")(world)()("hello 5")(world)()("hello 6")(world)()("hello 7")(world)()("hello 8")(world)()("hello 9")(world)()("hello 10")(world)()("hello 11")(world)))
    (Int64(0 1 0 1 2 2 2 3 4 3 4 6 4 5 8 5 6 10 6 7 12 7 8 14 8 9 16 9 10 18 10 11 20 11 12 22))
    (Int64_option((0)()()(0)()()(1)()()(1)()()(2)()()(2)()()(3)()()(3)()()(4)()()(4)()()(5)()()(5)()())) |}];
  let t = Table.slice t ~offset:8 ~length:5 in
  print_s ~mach:() ([%sexp_of: Column.t] (Column.experimental_fast_read t 0));
  print_s ~mach:() ([%sexp_of: Column.t] (Column.experimental_fast_read t 1));
  print_s ~mach:() ([%sexp_of: Column.t] (Column.experimental_fast_read t 2));
  print_s ~mach:() ([%sexp_of: Column.t] (Column.experimental_fast_read t 3));
  [%expect
    {|
    (String(v3 v1 v2 v3 v1))
    (String_option((world)()("hello 3")(world)()))
    (Int64(4 3 4 6 4))
    (Int64_option(()(1)()()(2))) |}]
