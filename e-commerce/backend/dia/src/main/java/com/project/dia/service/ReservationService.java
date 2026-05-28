package com.project.dia.service;

import com.project.dia.dao.PaymentDAO;
import com.project.dia.dao.ReservationDAO;
import com.project.dia.model.dto.ReservationDTO;
import com.project.dia.model.dto.WorkshopDTO;
import com.project.dia.model.vo.Payment;
import com.project.dia.model.vo.Reservation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ReservationService implements ReservationDAO {

    @Autowired
    private ReservationDAO reservationDAO;

    @Autowired
    private ProfitService profitService;

    @Autowired
    private PaymentDAO paymentDAO;

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private ScheduleService scheduleService;

    @Override
    public List<ReservationDTO> selectMyRV(int userId) {
        return reservationDAO.selectMyRV(userId);
    }

    @Override
    public ReservationDTO selectRVDetail(int reservationId) {
        return reservationDAO.selectRVDetail(reservationId);
    }

    @Override
    public List<ReservationDTO> wsReservation(WorkshopDTO dto) {
        return reservationDAO.wsReservation(dto);
    }

    @Override
    public int insertReservation(Reservation reservation) {
        return reservationDAO.insertReservation(reservation);
    }

    @Override
    public int updateReservation(Reservation reservation) {
        return reservationDAO.updateReservation(reservation);
    }

    @Override
    public List<Integer> findFinishedId() {
        return reservationDAO.findFinishedId();
    }

    @Override
    public void finishReservation(List<Integer> list) {
        reservationDAO.finishReservation(list);
    }

    @Override
    public List<ReservationDTO> viewFinishRV() {
        return reservationDAO.viewFinishRV();
    }

    @Override
    public void profitPaid(int reservationId) {
        reservationDAO.profitPaid(reservationId);
    }

    @Override
    public void cancelWaiting(List<Integer> scheduleIds) {
        reservationDAO.cancelWaiting(scheduleIds);
    }

    public int updateReservationStatus(int reservationId, String status) {
        Reservation vo = new Reservation();
        vo.setReservationId(reservationId);
        vo.setStatus(status);
        return reservationDAO.updateReservation(vo);
    }

    @Transactional
    public int paymentSuccess(Payment payment) {
        int result = paymentDAO.insertPayment(payment);

        if (result == 1) {
            // 예약 상태 '확정' 으로 업데이트
           updateReservationStatus(payment.getReservationId(), "확정");

            // 예약 인원, 스케줄 ID 받아오기
            ReservationDTO reservationDTO = reservationDAO.selectRVDetail(payment.getReservationId());

            // 스케줄 현재 인원 업데이트
            scheduleService.increaseAttendees(reservationDTO.getScheduleId(), reservationDTO.getNumPeople());
        }

        return result;
    }

    @Transactional
    public int cancelReservation(Reservation reservation) {
        int reservationId = reservation.getReservationId();

        // 결제 여부 확인
        int checkPaid = paymentDAO.checkPaymentStatus(reservationId);

        // 예약 상태 '취소' 로 업데이트
        int result = updateReservationStatus(reservationId, "취소");

        if (checkPaid == 0) {
            return result;
        }

        // 예약 상세정보 조회 (스케줄ID + 인원수)
        ReservationDTO reservationDTO = reservationDAO.selectRVDetail(reservationId);

        // 결제 상태 '환불'로 변경
        paymentService.updatePaymentStatus(reservationId, "환불");

        // 스케줄 인원 감소
        scheduleService.decreaseAttendees(reservationDTO.getScheduleId(), reservationDTO.getNumPeople());

        return result;
    }

    @Scheduled(cron = "0 * * * * *")
    public void reservationPaid() {
        // [1] 데드락 해결 로직 추가: 조회 후 업데이트
        // (위에서 연결한 findFinishedId()를 호출)
        List<Integer> finishedIds = this.findFinishedId();

        // 대상이 있을 때만 업데이트 실행
        if (finishedIds != null && !finishedIds.isEmpty()) {
            this.finishReservation(finishedIds);
            System.out.println("수강종료 처리 완료: " + finishedIds.size() + "건");
        }

        List<ReservationDTO> finishedReservations = viewFinishRV(); // 정산 대상 조회

        for (ReservationDTO r : finishedReservations) {
            try {
                profitService.profitSet(r);
                profitPaid(r.getReservationId());
            } catch(Exception e) {
                System.out.println("Profit 처리 중 오류: reservationId=" + r.getReservationId() + e);
            }
        }
    }

}
