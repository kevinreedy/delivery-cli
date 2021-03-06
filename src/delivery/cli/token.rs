//
// Copyright:: Copyright (c) 2016 Chef Software, Inc.
// License:: Apache License, Version 2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
use cli::arguments::{value_of, u_e_s_o_args};
use clap::{Arg, App, SubCommand, ArgMatches};

pub const SUBCOMMAND_NAME: &'static str = "token";

#[derive(Debug)]
pub struct TokenClapOptions<'n> {
    pub server: &'n str,
    pub port: &'n str,
    pub ent: &'n str,
    pub user: &'n str,
    pub verify: bool,
    pub raw: bool,
    // if None, use what the server tells us on its /e/<ent>/saml/enabled endpoint
    pub saml: Option<bool>,
}
impl<'n> Default for TokenClapOptions<'n> {
    fn default() -> Self {
        TokenClapOptions {
            server: "",
            port: "",
            ent: "",
            user: "",
            verify: false,
            raw: false,
            saml: None,
        }
    }
}

impl<'n> TokenClapOptions<'n> {
    pub fn new(matches: &'n ArgMatches<'n>) -> Self {
        TokenClapOptions {
            server: value_of(&matches, "server"),
            port: value_of(&matches, "api-port"),
            ent: value_of(&matches, "ent"),
            user: value_of(&matches, "user"),
            verify: matches.is_present("verify"),
            raw: matches.is_present("raw"),
            saml: match value_of(&matches, "saml") {
              "true" => Some(true),
              "false" => Some(false),
              _ => None,
            },
        }
    }
}

pub fn clap_subcommand<'c>() -> App<'c, 'c> {
    SubCommand::with_name(SUBCOMMAND_NAME)
        .about("Create a local API token")
        .args(&u_e_s_o_args())
        .args(&make_arg_vec![
            "--raw 'Output only the raw token string'",
            "--verify 'Verify the Token has expired'",
            "--api-port=[api-port] 'Port for Delivery server'",
            "--saml=[true/false] 'Use SAML authentication (overrides Delivery server)'"])
}
