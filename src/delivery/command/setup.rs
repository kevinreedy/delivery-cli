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

use cli;
use cli::setup::SetupClapOptions;
use types::{DeliveryResult, ExitCode};
use utils::say::sayln;
use utils::cwd;
use std::path::PathBuf;

pub fn run(opts: SetupClapOptions) -> DeliveryResult<ExitCode> {
    sayln("green", "Chef Delivery");
    let config_path = if opts.path.is_empty() {
        cwd()
    } else {
        PathBuf::from(opts.path)
    };
    let mut config = try!(cli::load_config(&config_path));
    config = config.set_server(opts.server)
        .set_user(opts.user)
        .set_enterprise(opts.ent)
        .set_organization(opts.org)
        .set_pipeline(opts.pipeline) ;
    try!(config.write_file(&config_path));
    Ok(0)
}
