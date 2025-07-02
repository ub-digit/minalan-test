import { library } from "@fortawesome/fontawesome-svg-core"
import {faCheckSquare,faCheck, faBan, faGlobe, faArrowLeft, faArrowRight, faTimes, faChevronDown, faChevronUp, faPlus, faMinus, faLock, faLockOpen} from "@fortawesome/free-solid-svg-icons"
import { faSquare} from "@fortawesome/free-regular-svg-icons"
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome"

library.add(faCheck, faBan, faGlobe, faArrowLeft, faArrowRight, faChevronDown, faChevronUp, faTimes, faPlus, faMinus, faSquare, faCheckSquare, faLock, faLockOpen);

function useFontawesome() {
  return {
    FontAwesomeIcon
  }
}

export { useFontawesome }