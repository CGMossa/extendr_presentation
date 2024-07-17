// #import "@preview/polylux:0.3.1": *
#import "polylux/polylux.typ": *

#import themes.minimetropolis: *
#set math.text(font: "Fira Sans",
  weight: "medium",
  ligatures: true)
#set text(
  font: "New Computer Modern",
  ligatures: true, weight: "medium")

#set page(paper: "presentation-16-9")

// #show: university-theme.with(aspect-ratio: "16-9")
#show: metropolis-theme.with(
  aspect-ratio: "16-9"
)
#set text(size: 25pt)
// #set strong(delta: 100)
#show link: set text(fill: fuchsia)
// #set par(justify: true)
#set footnote.entry(gap: 9pt, clearance: 0pt)
#show footnote.entry: set text(size: 15pt)


#show raw: set text(
  font: "Cascadia Code",
  weight: "medium",
  ligatures: true)

#let r = body => [
  // #show raw: set text(ligatures: true)
  #let body = if type(body) == content and body.func() == raw { body.text } else { body }
  #raw(lang: "r", body)
]

#let rust = body => [
  // #show raw: set text(ligatures: true)
  // SUGGESTION by PgSuper
  #let body = if type(body) == content and body.func() == raw { body.text } else { body }
  //
  #raw(lang: "rust", body)
]
  
#[
  #set text(size: 45pt)
  #title-slide(
    title: [`extendR`],
    subtitle: [Seamless integration between R and Rust],
    author: [
      #set text(size: 23pt)
      // #set text(justify: false)
      #set par(justify: false)
      Mossa Merhi Reimert, and others
      // "andy-thomason <andy@andythomason.com>",
      // "Thomas Down",
      // "Mossa Merhi Reimert <mossa@sund.ku.dk>",
      // "Claus O. Wilke <wilke@austin.utexas.edu>",
      // "Hiroaki Yutani",
      // "Ilia A. Kosenkov <ilia.kosenkov@outlook.com>",
      // "Michael Milton <michael.r.milton@gmail.com>",
      #box([
        #set text(size: 12pt)
        _Others_: Andy Thomason, Thomas Down, Claus O. Wilke, Hiroaki Yutani, Ilia A. Kosenkov, Michael Milton, 
      ])
    ]
  )
]

#slide(title: [What / Who uses R??])[
  #quote([R is a _free_ software environment for _statistical_ computing and graphics.]) -- #link("https://www.r-project.org/", "r-project.org").

  #pause

  - R is an interpreted language written in C.
  
  - R is the successor of S

  - Functional? Object-oriented? Imperative? 

  // Multi-paradigm? Robust? Stable? Etc.
]

#slide(
  title: [I'm Mossa.]
)[
  // #set align()
  // Formula training in (mathematical) Statistics,
  // (not )
  PhD Student in Veterinary Epidemiology, 
 
  MSc. in (mathematical) Statistics

  Interests: Simulator-based inference, Statistical inference

  Thesis is on Agent-based modelling of African Swine Fever between wild boars and domestic pigs


// #v(3em)

#grid(rows: 1, columns: 3,
  column-gutter: 3.5em,
  v(1.4em),
// #image("media/image7.png", width: 3em)
  grid(
    columns: 3, 
    image("media/image11.png", height: 3em),
    [ `<==>` ],
    image("media/image6.png", height: 3em)
  ),
  box(fill: red, height: 1.1em, clip: true, stroke: black)[
    DEADLINE: March 2024
  ]
)
  Supervisors: Matt Denwood, 	Maya Grussmann	Anette Boklund
]

#slide(title: [Why not R?])[
  R has many shortcomings, but for _us_.. 
  // But in the context of disease modelling, 
  
  //space efficient programs are impossible
  - Resource management; 

  - Concurrency support: Logging a model-run, should happen irrespective of the model calculations.

  // Vectorised operations are great, but it doesn't vectorise custom
  // written operations, like monte carlo-like procedures,  
  - No auto-vectorisation, even summing flat numbers is difficult, see #link("https://www.wikiwand.com/en/Kahan_summation_algorithm", [Kahan Summation Algorithm])

  - Performance critical code is a multi-faceted challenge...
  // Clarity suffers at the alter of performance.
  // It is not unusual in R-circles to suggest things, that will
  // increase the performance, to the detrement of clarity, modularity,
  // to the extent that it obfuscates
]

#slide(title: [Worry not, R is meant to be extended])[
  #set pad(right: 2em)

  - Official documentation for extending R (#link("https://cran.r-project.org/doc/manuals/R-exts.html", "R-exts")) supporting `C/C++/Fortran`
  
    // examples of automatically generate bindings from one language,
    // to R

  - Rcpp, cpp11, rJava, reticulate (python), RJulia, 
  // #link("https://cran.r-project.org/web/packages/Rcsdp/index.html", "Rcsdp")

  R provides a C-API#footnote([R lingo: C-facilities]) that can be used as an ABI

]


#slide(title: [Why Rust?])[
  - Compiled language like C/C++ with comparable performance
  
  - Declarative memory management (no pointers!)
  
  - No exceptions (#r(`tryCatch`) / #r(`on.exit`))
  
  - No object-oriented programming, trait-based dispatch
  
  - No garbage collector / heavy runtime

  Rust's sales pitch is: Safety & security critical code for systems programming. Or "if it compiles, it works"

  // References:
  // #link("https://github.com/thoughtworks/epirust/wiki/Motivation-Behind-EpiRust", [Motivation Behind `EpiRust`]), by @kshirsagarEpiRustFrameworkLargescale2021, evaluating rust for ABMs
  // @antelmiEvaluatingRustProgramming2019; Lange group uses Rust for their ASF wild boar model
]

// #slide()[
//   // There are several frameworks for using agent-based modelling: 
//   // @correaRustagentbasedmodels2023,
//   // @KrABMaga2023,
//   // @kshirsagarEpiRustFrameworkLargescale2021

//   The goal isn't to make general-purpose framework.

//   Instead, custom-built models in Rust, and have the ability to amend / interact with these in R...

//   Hence, `extendR`!
  
// ]

// #slide(title: [Why not our R models?])[

//   They are convoluted, by design, as to make them work with R's computational constraints.
//   // A "simple" construction will not be fast, i.e. using lists, and for-loops
//   // An idea that comes in is using matrices / arrays, that
//   // entails making all operations in that way
//   // which  makes the model unreadable, as the operations performed are non-standard to R, (like shuffling)
  
//   They are still slow. 
  
//   - No ABC / SMC procedure can be built on top (to estimate epidemiological parameters on the available  data)
  
//   - No sufficiently complex mechanism can be implemented in them.
//   // Advanced dispersal for WB gets too complicated
//   // - Running the WB Model together with the DPP Model wasn't going to work anyways
// ]


#slide(title: [Use case])[
  Problem: Logging some state of a complex simulator.
  
  Solution:

```R
write.table(file = logging_file_name[['state_name']],
  current_state, append = TRUE, col.names = FALSE)
```
 (1) Initialize the table with #r(`col.names = TRUE`), (2) ensure that state can flattened, (3) ensure that the file matches the state being processed
]

#slide(title: [Use case ])[



  - `if`-statement to determine whether to log (hot path)
  #text(size: 0.8em)[ 
    _Actual_: You could use #link("https://github.com/r-lib/debugme", "{debugme}"), and depend on `.onLoad`-behavior
  ]
  
  - Buffered IO operation even in the case of a crash

  - _Serialisation of state_

  - Logging in another thread // than main thread

  All of this can be done in Rust, with less effort and more guarantees
  
  #pause

  (skipping this unfortunately)
]

#slide(title: [What is `extendR`?])[
  
  #align(center)[
    `extendR` is composed of 3 parts
  ]
  
  \[Rust / requires C\] \
  System bindings through `libR-sys`
  // Exposing R's C-API / C-facilities
  
  \[Rust\] \
  `extendr` that contains an API, procedural macros, and engine.
  
  \[R\] \
  `rextendr` an r-package interface to extendr 

  See #link("https://extendr.github.io/").
]

#slide(title: [Getting started with `extendR`])[
  ```r
  remotes::install_github("extendr/rextendr")
  usethis::create_package("vetEpiRust")
  rextendr::use_extendr()
  ```

  Rust project is in `./vetEpiRust/src/rust/`

  #pause 

  Daily tool: #r("rextendr::document()").

  #pause

  `rextendr` also have `rust_source` and `rust_function` equivalent to `Rcpp`'s functions..
]


#slide(title: [`extendr`: Example])[

  // explain rust syntax, mention lifetimes, doc-comment, last
  // expressions has an implicit return

  ```rs
  /// Return string `"Hello world!"` to R.
  /// @export
  #[extendr]
  fn hello_world() -> &'static str {
      "Hello world!"
  }
  ```

  #pause

  `#[extendr]` exports the function to the surrounding r-package
  
  `@export` exports the function to importing r-packages
  // that updates the `NAMESPACE`-file when invoking `rextendr::document()`.

]

#slide(title: [Concludes the sales pitch for extendR!])[

  That's it!

  #pause 

  Rest of the talk is on extendR internals.
]

#slide(title: [Let's inspect the R's internals...])[
  // #set text(size: 20pt)
  ```r
> hello_world()
[1] "Hello world!"
> .Internal(inspect(hello_world()))
@0x000001f379d4d6b0 16 STRSXP g0c1 [] (len=1, tl=0)
  @0x000001f3747398c8 09 CHARSXP g1c2 [MARK,REF(5),gp=0x60,ATT] [ASCII] [cached] "Hello world!"
  ```
  Regular R:
  ```r
  > .Internal(inspect("Hello world!"))
@0x000001f3797b0510 16 STRSXP g0c1 [REF(2)] (len=1, tl=0)
  @0x000001f3747398c8 09 CHARSXP g1c2 [MARK,REF(6),gp=0x60,ATT] [ASCII] [cached] "Hello world!"
  ```
]

#slide(title: [String interning])[
  // #set align(horizon)
  Strings in R are interned, i.e. they are static!

  `=>` same address on the two strings!

  #pause
  #v(1em)

  A string-vector is a vector of strings

  `=>` String-vectors are not interned!

  `==>` Different pointers
  // Therefore the element in the string-type is the same
  // data, but not the string vector!
]

// #slide(title: [ExtendR features])[
//   - Conversions between R and Rust types.
  
//   - Interfacing from R into Rust, by generating wrappers / `.Call`
  
//   - Interfacing from Rust to R, by emulating R inside of Rust, and accessing R's C-API single-threaded
  
//   - Running R inside of Rust 
  
//   - Publishing Rust-powered R-packages on CRAN
// ]


// #slide(title: [`extendr`: Conversions])[
//   There are only #r("integer()") / #rust("i32") and #r("numeric()") / #rust("f64").

//   For R to use a value, it needs to be allocated by R.
  
//   For Rust to use a value, it can be allocated in either.

//   *But R's API is single-threaded.*
// ]

// #slide(title: [`extendr` allocations])[
//   Currently, `extendr` protects everything it allocates via R's C-API.

//   Thus, `extendr` protects things that don't need protection.

//   `R` supports local protection mechanism, which are efficient, and global protection mechanism, which are slower.

//   ExtendR provides `Logicals`, `Integers`, `Doubles`, etc.
//   and we can access them as native Rust slices, i.e. `&[T]` / `&mut [T]`. 
// ]

// #slide(title: [`extendr`'s protection / `ownership`-module])[
//   Currently, `extendr` treats `SEXP`s as Reference Counted variables.

//   My proposal is to move into #rust("Box<_>") / #raw(lang:"c++", "std::unique_ptr") way of thinking.
  
// ]

#slide(title: [Overview!])[
  1. Call a C-function from R.

  2. Call a Rust-function from C.

  #pause

  Load the library (`.so`/`.dll`) in R, using `dyn.load("shlib_file")`. 
  // .so in unix and dll in windows

  Then:
  #pad(left: 1em)[
  ```R
  // Help: .Call(.NAME, ..., PACKAGE)
  return_value <- .Call("c_function_name", args)
  ```
  ]

]

#slide(title: [Overview])[
  A C-function in Rust:

  ```rs
  #[no_mangle]
  pub extern "C" fn c_function_name() {
    rust_function_name()
  }
  ```

  #pause

  What about the data??
]

#slide(title: [Overview])[
  In R:
  - Fundamental types: #r(`integer()`) / #rust(`i32`) and #r(`numeric()`) / #rust("f64")

  - `logical()` is a derivative of #rust("i32")

  // - Strings are complicated
  #pause

  In R's C-API:
  - Everything in R is a pointer-type called `SEXP`.

  - R uses integers to indiciate types (C-style)

  - e.g. `list()` is a vector of `SEXP`s.

]


#slide(title: [Overview])[
  A C-function in Rust:

  ```rs
  #[no_mangle]
  pub extern "C" fn c_function_name(arg1: SEXP, arg2: SEXP) -> SEXP {
    // convert arg1, arg2 from `SEXP`s to concrete types
    let rust_return_value = rust_function_name(arg1, arg2);
    let result = // same here..
    result
  }
  ```
]

#slide(title: [Requirements for the abstractions])[

  Goal: Adapt the C-style API to a idiomatic rust API

  - Define marshalling between R and Rust...

  i.e. go from an r-type to a rust-type in a zero-cost manner

  - Use R's GC protection mechanisms 

  // but don't annoy the user about this.

  #pause

  Minimal definition:

  #pad(left: 1em)[
    ```rs
    pub struct Robj {
        inner: SEXP,
    }
    ```
  ]
  // can't include anything else, because then we break the seamless conversion from a pointer to a slice..

  // Creating `Robj` incurs a registration in `ownership-module`, encurs a registration, not an increase in RC.
]

#slide(title: [Slices are vectors?])[

  C-style `(ptr, len)` is represented as a slice in Rust #rust(`&[T]`) / #rust(`&mut [T]`).

  // A rust pointer is either #rust(`*const T`) or #rust(`*mut T`)
  // ... but this distinction is lost on R's C-api

  #pause

  `=>` `Robj` can only contain the pointer then!
  
  Rust conversion:
  ```rs
  pub const unsafe 
    fn from_raw_parts<'a, T>(data: *const T, len: usize) -> &'a [T]
  ```

  // it is here where you define all the specific conversions adopted

  // also what about owned vectors?

  #pause

  Unprotect R-data (owned by Rust), once Rust is done with them

  `=>` Add a `Drop`-mechanism to `Robj`
]

#slide(title: [Is this accurate?])[
  R's protection mechanism are specific

  - You allocate it, you protect it
    - Returning to R means that _R now protects it_

  - A protected _thing_ protects everything it contains

  There is a stack-based fast protection mechanism in R...


  But it has a vaguely undocumented limit of 10k-calls or so

  `=>` Rust has to know about the protection
  // There is an efficient protection mechanism to use in case of
  // data intensive 
]

#slide(title: [Strategies? [Audience question]])[

  As an `extendR` contributor, \ 
  #h(1em) you'll have to uncover what strategy works:

  - Amend `Robj` with protection status?

  - Use an `enum` / `union` instead to represent `Robj`?

  - Amend the pointer `SEXP` with the protection information?

  
  Any ideas from the audience?

]

#slide(title: [Proposal: the `enum`])[
  ```rs
  pub enum Robj {
    /// Protected by R, or a symbol
    Permanent(RawRobj),
    /// Unprotected / free R object
    Raw(RawRobj),
    /// Owned (by Rust), meaning it has to be freed by Rust
    Owned(RawRobj),
}
  ```

  // A permanent is like the internet strings, should we do string comparison or just look up the pointer? what is faster?
  
  // We can have one result that is protected, and if we need
  // to make micro protections 

  More on this on #link("https://github.com/extendr/extendr/issues/608", "#608") on GitHub...
]


// #slide(title: [Why is this an issue?])[
//   - Allocating large vectors requires that we protect / unprotect locally. 
  
//     Using `PROTECT` / `UNPROTECT` is not possible, because there is an arbitrary limit of #sym.approx 10k on `PROTECT`-calls.

//   - Benchmarks against `{Rcpp}`...
  
// ]

#slide(title: [Another topic: Embedding Rust types in R])[
  Coarsing a granular rust-data to R is very limited

  How about embedding rust data `T` in R?

  // collapsing a granular Rust object to R might not be beneficial
  // if that structure is needed for further processing
  
  // Thus it should have parts where the rust code interacts with R data
  // to have a state that is consumable by R

  // See 
  // #link("https://github.com/gmbecker/SearchTrees", `{searchTrees}`).
]

#slide(title: [Embedding `T` in R])[
  Embedding Rust data in R is done through 
  #rust(`ExternalPtr<T>`)#footnote(link("https://cran.r-project.org/doc/manuals/R-exts.html#External-pointers-and-weak-references", [External pointers and Weak references in R-exts.]))

  ```C
  SEXP R_MakeExternalPtr(void *p, SEXP tag, SEXP prot);
  ```

  `tag` is an identifier for type,
  `prot` are accompanying R-data that is protected as long as `ExternalPtr<T>` is alive.

  ... there are other stuff
  
]

#slide(title: [Vision / Today])[
  #side-by-side(
    [
    ```rust
    #[extendr]
    struct Scenario {
      rust_data: Vec<i32>,
      #[extendr]
      r_data: Integers
      #[extendr(readonly)]
      r_data_2: Rint,
      // ???
      ambigious_data: LikeRobj,
    }
    ``` 
    ],
    [
      For methods, we already have
      ```rs
      #[extendr]
      impl Scenario {
        pub fn update(&mut self) {
          todo!()
        }
      }
      ```
    ]
  )
  // Register `r_data` in `prot`, and respect `pub`-status.
]

#slide(title: [Next steps])[ 
  Writing self-protected types

  Enable S4/RC/R6/S7 objects to use the above
]

// #slide(title: [Vision])[
//   This enables composing R and Rust function, because both can interact with each other.

//   \ \

// _  Prerequisites for this: Emulating R-data in Rust, interfacing without reallocation, generation of wrappers..
// _]


#slide(title: [Call for Participation])[

  - Add instrumentation to our current r-object gc/protection

  - Integrate with #link("https://docs.r-wasm.org/webr/latest/", "webR")

  - #strike([Make `extendR` thread-safe], stroke: gray) write multithreading tests

  - Integrate S7#footnote([
    #link("https://cran.r-project.org/web/packages/S7/vignettes/S7.html", "Official S7 documentation") and
    #link("https://www.jumpingrivers.com/blog/r7-oop-object-oriented-programming-r/", "What is S7? A New OOP System for R", )])
  
  - Proc-macro for custom ALTREP#footnote([
    #link("https://github.com/ALTREP-examples", "ALTREP examples")
  ])

  #pause
  We have a (friendly!) Discord!
  #link("https://discord.gg/XAjKbDCW")
]


#slide(title: [References])[
    #set text(size: 18pt)
    
    // #bibliography("assessment.bib", title: none)
]


#focus-slide([
  #set text(size: 69pt)
  _*Graveyard*_])


#slide(title: [`extendr`'s R Exporting / Namespace])[
  An R-package is a `DESCRIPTION` + `NAMESPACE`.
  // a description is which namespaces are imported,
  // and which are names are  exported

  An R-package has only one namespace #sym.subset module.

  `#[extendr]` exports to R, and `@export` exports to `NAMESPACE`, i.e. other R-packages.

  ```rust
  extendr_module! {
      mod vetEpiRust;
      fn hello_world;
  }
  ```
]

#slide(title: [`extendr` another module?])[
  ```rs
    extendr_module! {
        mod wild_boar_model;
        use landscape_generation;
        use distance_weights_function;
        impl sir_model;
        fn run_until_outbreak;
    }
  ```
  `mod` defines current module, `use` exports another module, `fn` exports a function, `impl` exports a Rust `struct`.
]


#slide(title: [Challenges])[

  Open problems:
    
    - Can `#[extendr]`-functions call other `#[extendr]`-functions?
    
  Esoteric API design: Embedding R abstractions in Rust
]


#slide(title: [What's an ECS])[
  ECS is analogous to a database, i.e. `World`-type.

  By describing entities (ids), to components (data), and systems (functions that requests `(id, data)`), it infers the *tables*#footnote("Archetypal storage") that the database should contain.

  Functions describe which table they require, and the database caches this.
]


#slide(title: [Advantages of an ECS])[
  Use an Entity Component System to build the model, and configure it with and w/e self-correcting processes

  Describe and demonstrate: 
  
  - Concurrent logging & sparse logging due to change-detection in ECS frameworks
  
  - Batched scenario repetitions by using Entity Relations in ECS framework
]

// #slide(title: [Flecs])[
  
// ]
