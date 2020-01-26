package nsc.iot.api;

import nsc.iot.bean.APIResponse;
import nsc.iot.model.service.CardRepository;
import nsc.iot.model.service.MQTTDataRespository;
import nsc.iot.model.table.Card;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/card")
public class CardAPI {

    @Autowired
    private CardRepository cardRepository;

    @Autowired
    private MQTTDataRespository mQTTDataRespository;

    @GetMapping("/save")
    public Object save(@RequestParam String title, @RequestParam int userId, Card card) {
        APIResponse res = new APIResponse();
        cardRepository.save(card);
        res.setStatus(0);
        res.setMessage("success");
        res.setData(card);
        return res;
    }

    @GetMapping("/list")
    public Object list(@RequestParam int userId) {
        APIResponse res = new APIResponse();
        List<Card> cards = cardRepository.findByUserId(userId);

        if (cards != null && !cards.isEmpty()) {
            res.setStatus(0);
            res.setMessage("success");
            res.setData(cards);
        } else {
            res.setStatus(1);
            res.setMessage("no card");
        }
        return res;
    }

    @GetMapping("/updateData")
    public Object updateData(@RequestParam int userId, @RequestParam int idCard, @RequestParam String dataNow) {
        APIResponse res = new APIResponse();
        Card card_db = cardRepository.findByUserIdAndId(userId, idCard);
        if (card_db != null) {
            res.setStatus(0);
            cardRepository.updateDataNewToCard(idCard, userId, dataNow);
            res.setMessage("success");
        } else {
            res.setStatus(1);
            res.setMessage("no massage");
        }
        return res;
    }

    @GetMapping("/delete")
    public Object Delete(@RequestParam int idCard) {
        APIResponse res = new APIResponse();
        Optional<Card> cards = cardRepository.findById(idCard);
        System.out.println(cards);
        if (!cards.isEmpty()) {
            cardRepository.deleteById(idCard);
            res.setStatus(0);
            res.setMessage("success");
        } else {
            res.setStatus(1);
            res.setMessage("no card delete");
        }
        return res;
    }

    @GetMapping("/edit")
    public Object Edit(@RequestParam String title, @RequestParam int userId, @RequestParam int id, Card card) {
        APIResponse res = new APIResponse();
        Optional<Card> cards = cardRepository.findById(id);
        if (!cards.isEmpty()) {
            cardRepository.save(card);
            res.setStatus(0);
            res.setMessage("success");
        } else {
            res.setStatus(1);
            res.setMessage("no card");
        }
        return res;
    }
}
