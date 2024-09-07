package example

import com.google.cloud.functions.{HttpFunction, HttpRequest, HttpResponse}
import esc.similarity._
import esc.utils.Persistence._

class PersonNameExplanation extends HttpFunction:
  override def service(request: HttpRequest, response: HttpResponse): Unit =
    val nameA = request.getFirstQueryParameter("nameA").orElse("Unknown")
    val nameB = request.getFirstQueryParameter("nameB").orElse("Unknown")
    val nameSimilarity = NameSimilarity()
    response.setContentType("application/json")
    response.getWriter.write(
      nameSimilarity.explainPersonNameSimilarity(nameA, nameB).toCompactJson
    )

class OrganisationNameExplanation extends HttpFunction:
  override def service(request: HttpRequest, response: HttpResponse): Unit =
    val nameA = request.getFirstQueryParameter("nameA").orElse("Unknown")
    val nameB = request.getFirstQueryParameter("nameB").orElse("Unknown")
    val nameSimilarity = NameSimilarity()
    response.setContentType("application/json")
    response.getWriter.write(
      nameSimilarity.explainOrganisationNameSimilarity(nameA, nameB).toCompactJson
    )