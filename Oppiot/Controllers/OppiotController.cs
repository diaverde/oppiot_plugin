using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

using Oppiot.Models;

namespace Oppiot.Controllers
{
    [ApiController]
    [Route("api/Oppiot")]
    public class OppiotController : ControllerBase
    {
        private IOppiotReaderService _oppiotService;

        public OppiotController(IOppiotReaderService oppiotService)
        {
            _oppiotService = oppiotService;
        }

        [HttpGet("connect")]
        public ActionResult<bool> Connect()
        {
            if (_oppiotService == null)
            {
                return NotFound();
            }
            string result = _oppiotService.OpenPort();
            if (result.StartsWith("Error"))
            {
                //return result;
                return false;
            }
            else
            {
                return true;
            }
        }

        [HttpGet("disconnect")]
        public ActionResult<bool> Disconnect()
        {
            if (_oppiotService == null)
            {
                return NotFound();
            }
            if (_oppiotService.ClosePort().StartsWith("Error"))
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        [HttpGet("info")]
        public ActionResult<string> GetInfo()
        {
            if (_oppiotService == null)
            {
                return NotFound();
            }
            return (_oppiotService.GetInfo());
        }

        [HttpGet("inventory")]
        public ActionResult<string> Inventory()
        {
            if (_oppiotService == null)
            {
                return NotFound();
            }
            return _oppiotService.Inventory();
        }

        [HttpGet("tagWrite")]
        public ActionResult<bool> TagWrite(string dataToWrite)
        {
            if ((dataToWrite == null) || (dataToWrite == ""))
            {
                return NotFound();
            }
            if (_oppiotService == null)
            {
                return NotFound();
            }
            return (_oppiotService.TagWrite(dataToWrite));
        }

    }
}