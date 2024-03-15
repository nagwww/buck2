/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under both the MIT license found in the
 * LICENSE-MIT file in the root directory of this source tree and the Apache
 * License, Version 2.0 found in the LICENSE-APACHE file in the root directory
 * of this source tree.
 */

use std::ptr;

use buck2_wrapper_common::win::winapi_handle::WinapiHandle;
use winapi::um::jobapi2;
use winapi::um::winnt::HANDLE;

use crate::win::utils::result_bool;
use crate::win::utils::result_handle;

pub(crate) struct JobObject {
    handle: WinapiHandle,
}

impl JobObject {
    pub(crate) fn new() -> anyhow::Result<Self> {
        let handle = result_handle(unsafe {
            WinapiHandle::new(jobapi2::CreateJobObjectW(ptr::null_mut(), ptr::null_mut()))
        })?;
        Ok(Self { handle })
    }

    pub(crate) fn assign_process(&self, process: HANDLE) -> anyhow::Result<()> {
        result_bool(unsafe { jobapi2::AssignProcessToJobObject(self.handle.handle(), process) })
    }

    pub(crate) fn terminate(&self, exit_code: u32) -> anyhow::Result<()> {
        result_bool(unsafe { jobapi2::TerminateJobObject(self.handle.handle(), exit_code) })
    }
}
