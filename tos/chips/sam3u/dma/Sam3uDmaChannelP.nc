/*
* Copyright (c) 2009 Johns Hopkins University.
* All rights reserved.
*
* Permission to use, copy, modify, and distribute this software and its
* documentation for any purpose, without fee, and without written
* agreement is hereby granted, provided that the above copyright
* notice, the (updated) modification history and the author appear in
* all copies of this source code.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  `AS IS'
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED  TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR  PURPOSE
* ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR  CONTRIBUTORS
* BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, LOSS OF USE,  DATA,
* OR PROFITS) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
* CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR  OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
* THE POSSIBILITY OF SUCH DAMAGE.
*/

/**
 * @author JeongGil Ko
 */

#include "sam3uDmahardware.h"

generic module Sam3uDmaChannelP() {

  provides interface Sam3uDmaChannel as Channel;
  uses interface HplSam3uDmaChannel as DmaChannel;
}

implementation {

  async command error_t Channel.setupTransfer( uint8_t channel,
					       void *src_addr,
					       void *dst_addr,
					       uint16_t btsize,
					       dmac_chunk_t scsize,
					       dmac_chunk_t dcsize,
					       dmac_width_t src_width,
					       dmac_width_t dst_width,
					       dmac_dscr_t src_dscr,
					       dmac_dscr_t dst_dscr,
					       dmac_fc_t fc,
					       dmac_inc_t src_inc,
					       dmac_inc_t dst_inc,
					       uint8_t src_per,
					       uint8_t dst_per,
					       bool srcSwHandshake,
					       bool dstSwHandshake,
					       bool stopOnDone,
					       bool lockIF,
					       bool lockB,
					       dmac_IFL_t lockIFL,
					       dmac_ahbprot_t ahbprot,
					       dmac_fifocfg_t fifocfg)
  {

    call DmaChannel.enable();
    call DmaChannel.setSrcAddr(src_addr);
    call DmaChannel.setDstAddr(dst_addr);
    call DmaChannel.setCtrlA(1, 0, 0, 0, 0);
    call DmaChannel.setCtrlB(1, 1, 0, 2, 2);
    call DmaChannel.setCfg(0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

    /*
    call DmaChannel.enable();
    call DmaChannel.setSrcAddr(src_addr);
    call DmaChannel.setDstAddr(dst_addr);
    call DmaChannel.setCtrlA(btsize, scsize, dcsize, src_width, dst_width);
    call DmaChannel.setCtrlB(src_dscr, dst_dscr, fc, src_inc, dst_inc);
    call DmaChannel.setCfg(src_per, dst_per, srcSwHandshake,
			   dstSwHandshake, stopOnDone, lockIF,
			   lockB, lockIFL, ahbprot,
			   fifocfg);
    */
    return SUCCESS;
  }

  async command error_t Channel.startTransfer(uint8_t channel, bool s2d)
  {
    call DmaChannel.enable();
    call DmaChannel.enableChannelInterrupt(channel);
    call DmaChannel.enableChannel(channel, s2d);
    return SUCCESS;
  }

  async command error_t Channel.repeatTransfer( void *src_addr, void *dst_addr, uint16_t size, uint8_t channel, bool s2d)
  {
    call DmaChannel.setSrcAddr(src_addr);
    call DmaChannel.setDstAddr(dst_addr);
    call DmaChannel.setBtsize(size);    
    return call Channel.startTransfer(channel, s2d);
  }

  async command error_t Channel.swTrigger(uint8_t channel, bool s2d)
  {
    // call DmaChannel.enableChannel(channel, s2d); // start tx!
    return SUCCESS;
  }

  async command error_t Channel.stopTransfer(uint8_t channel)
  {
    /* Check Chapter 40.3.6 */
    //call DmaChannel.readChsrEnable()

  }

  async command error_t Channel.resetAll()
  {
    return SUCCESS;
  }


  async event void DmaChannel.transferDone(error_t success){
    signal Channel.transferDone(success);
  }

  default async event void Channel.transferDone(error_t success){
  }

}